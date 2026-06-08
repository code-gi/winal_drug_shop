from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
    get_jwt
)
from app.models.user import User
from app.schemas import UserSchema
from app.schemas.schemas import LoginSchema, PasswordResetRequestSchema, PasswordResetSchema, PasswordResetWithCodeSchema
from marshmallow import ValidationError
from app import db
from datetime import datetime, timedelta, timezone
import bcrypt
import os
from app.utils.validation import validate_email
from app.utils.gmail_service import send_password_reset_email, verify_code, clear_verification_code
from app.utils.error_formatting import format_validation_errors

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    # Get request data
    data = request.get_json()
    if not data:
        return jsonify({'message': 'No data provided'}), 400

    # Convert date format if provided
    if 'date_of_birth' in data:
        try:
            # Convert from "M/D/YYYY" to "YYYY-MM-DD"
            dob = datetime.strptime(data['date_of_birth'], '%m/%d/%Y')
            data['date_of_birth'] = dob.strftime('%Y-%m-%d')        
        except ValueError as e:
            return jsonify({
                'message': 'Invalid date format',
                'error': 'Date must be in format MM/DD/YYYY'
            }), 400

    print(f"Registration request data: {data}")  # Debug print
    
    # Get and validate data using UserSchema
    schema = UserSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        print(f"Validation error: {err.messages}")  # Debug print
        
        # Use the error formatting utility
        formatted_response = format_validation_errors(err.messages)
        return jsonify(formatted_response), 400

    # Check if user already exists
    if User.query.filter_by(email=validated_data['email']).first():
        return jsonify({'message': 'Email already registered'}), 400

    # Create new user
    try:
        new_user = User(
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            phone_number=validated_data.get('phone_number'),
            date_of_birth=validated_data.get('date_of_birth')
        )
        db.session.add(new_user)
        db.session.commit()
        
        # Generate tokens
        access_token = create_access_token(identity=new_user.id)
        refresh_token = create_refresh_token(identity=new_user.id)

        # Send welcome email
        try:
            from app.utils.gmail_service import send_welcome_email
            send_welcome_email(new_user.email, new_user.first_name)
            print(f"Welcome email sent to {new_user.email}")
        except Exception as e:
            # Don't interrupt registration if email fails
            print(f"Error sending welcome email: {str(e)}")
            current_app.logger.error(f"Welcome email error: {str(e)}")

        return jsonify({
            'message': 'Registration successful',
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': new_user.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error creating user: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login and receive JWT token"""
    data = request.get_json()
      # Validate input data using LoginSchema
    from app.schemas.schemas import LoginSchema
    schema = LoginSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        formatted_response = format_validation_errors(err.messages)
        return jsonify(formatted_response), 400
    
    user = User.query.filter_by(email=validated_data['email'].lower()).first()
    
    if not user or not user.verify_password(validated_data['password']):
        return jsonify({
            "message": "Invalid credentials",
            "field_errors": {
                "email": {
                    "errors": ["Invalid email or password"],
                    "requirement": "Please check your email and password",
                    "field_name": "Email"
                },
                "password": {
                    "errors": ["Invalid email or password"],
                    "requirement": "Please check your email and password",
                    "field_name": "Password"
                }
            },
            "summary": "Login failed - please check your credentials",
            "total_errors": 2
        }), 401
    
    access_token = create_access_token(
        identity=user.id,
        expires_delta=timedelta(days=1)
    )
    
    return jsonify({
        "message": "Login successful",
        "access_token": access_token,
        "user": {
            "id": user.id,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name
        }
    }), 200

@auth_bp.route('/token-debug', methods=['GET'])
@jwt_required()
def token_debug():
    current_user_id = get_jwt_identity()
    return jsonify({"message": "Token is valid", "user_id": current_user_id}), 200

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh_token():
    """Refresh access token"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    # Generate new access token with extended expiration for admin users
    expires_delta = timedelta(days=7) if user.is_admin else timedelta(hours=1)
    new_access_token = create_access_token(
        identity=user_id,
        expires_delta=expires_delta
    )
    
    return jsonify({
        'access_token': new_access_token,
        'message': 'Token refreshed successfully'
    }), 200

@auth_bp.route('/check-email', methods=['POST'])
def check_email():
    """Check if email exists in the system"""
    try:
        data = request.get_json()
        print(f"Check-email request data: {data}")
        
        # Validate input data using PasswordResetRequestSchema
        schema = PasswordResetRequestSchema()
        try:
            validated_data = schema.load(data)
        except ValidationError as err:
            formatted_response = format_validation_errors(err.messages)
            return jsonify(formatted_response), 400
        
        email = validated_data['email'].lower()
        
        # Check if user exists
        user = User.query.filter_by(email=email).first()
        
        if not user:
            print(f"Email not found: {email}")
            return jsonify({
                "message": "Email not found",
                "field_errors": {
                    "email": {
                        "errors": ["Email not found"],
                        "requirement": "Please enter a valid registered email address",
                        "field_name": "Email"
                    }
                },
                "summary": "Email not found in our system",
                "total_errors": 1
            }), 404
        
        print(f"Email exists: {email}")
        return jsonify({"message": "Email exists"}), 200
    except Exception as e:
        print(f"Error in check-email: {str(e)}")
        current_app.logger.error(f"check-email error: {str(e)}")
        return jsonify({"message": "Internal server error", "error": str(e)}), 500

@auth_bp.route('/request-reset', methods=['POST'])
def request_reset():
    """Request password reset"""
    data = request.get_json()
    
    # Validate input data using PasswordResetRequestSchema
    schema = PasswordResetRequestSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        formatted_response = format_validation_errors(err.messages)
        return jsonify(formatted_response), 400
    
    email = validated_data['email'].lower()
    
    # Check if user exists
    user = User.query.filter_by(email=email).first()
    
    if not user:
        # For security reasons, don't reveal if the email exists
        return jsonify({"message": "If the email exists, a password reset link will be sent"}), 200
    
    # Send password reset email
    try:
        # The email service will generate and store a verification code
        send_password_reset_email(user.email, user.first_name)
        return jsonify({"message": "Password reset instructions sent"}), 200
    except Exception as e:
        current_app.logger.error(f"Password reset email error: {str(e)}")
        return jsonify({"message": "Failed to send password reset email"}), 500

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    """Reset password with verification code"""
    data = request.get_json()
    
    # Validate input data using PasswordResetWithCodeSchema
    schema = PasswordResetWithCodeSchema()
    try:
        validated_data = schema.load(data)
    except ValidationError as err:
        formatted_response = format_validation_errors(err.messages)
        return jsonify(formatted_response), 400
    
    email = validated_data['email'].lower()
    verification_code = validated_data['verification_code']
    new_password = validated_data['new_password']
    
    # Check if user exists
    user = User.query.filter_by(email=email).first()
    
    if not user:
        return jsonify({
            "message": "User not found",
            "field_errors": {
                "email": {
                    "errors": ["Email not found"],
                    "requirement": "Please enter a valid registered email address",
                    "field_name": "Email"
                }
            },
            "summary": "Email not found in our system",
            "total_errors": 1
        }), 404
    
    # Verify the code
    try:
        print(f"Attempting to verify code: '{verification_code}' for email: '{email}'")
        is_valid = verify_code(email, verification_code)
        print(f"Code verification result: {is_valid}")
        if not is_valid:
            return jsonify({
                "message": "Invalid verification code",
                "field_errors": {
                    "verification_code": {
                        "errors": ["Invalid or expired verification code"],
                        "requirement": "Please enter the correct verification code sent to your email",
                        "field_name": "Verification Code"
                    }
                },
                "summary": "Verification code is invalid or expired",
                "total_errors": 1
            }), 400
        
        # Update password - use the User model's password setter
        user.password = new_password  # This will use the setter method which hashes the password
        db.session.commit()
        
        # Clear the verification code after successful reset
        clear_verification_code(email)
        print(f"Password reset successful for email: {email}")
        
        return jsonify({"message": "Password reset successful"}), 200
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Password reset error: {str(e)}")
        return jsonify({"message": "Error resetting password"}), 500
