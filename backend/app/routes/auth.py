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
from marshmallow import ValidationError
from app import db
from datetime import datetime, timedelta, timezone
import bcrypt
import os
from app.utils.validation import validate_email
from app.utils.gmail_service import send_password_reset_email, verify_code, clear_verification_code

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
        return jsonify({
            'message': 'Validation error',
            'errors': err.messages
        }), 400

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
            date_of_birth=datetime.strptime(data['date_of_birth'], '%Y-%m-%d').date() if 'date_of_birth' in data else None
        )
        db.session.add(new_user)
        db.session.commit()

        # Generate tokens
        access_token = create_access_token(identity=new_user.id)
        refresh_token = create_refresh_token(identity=new_user.id)

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
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"message": "Email and password required"}), 400
    
    user = User.query.filter_by(email=data['email'].lower()).first()
    
    if not user or not user.verify_password(data['password']):
        return jsonify({"message": "Invalid credentials"}), 401
    
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
    try:
        data = request.get_json()
        print(f"Check-email request data: {data}")
        
        if not data or not data.get('email'):
            print("Missing email in request data")
            return jsonify({"message": "Email is required"}), 400
        
        email = data['email'].lower()
        
        # Validate email format
        if not validate_email(email):
            print(f"Invalid email format: {email}")
            return jsonify({"message": "Invalid email format"}), 400
        
        # Check if user exists
        user = User.query.filter_by(email=email).first()
        
        if not user:
            print(f"Email not found: {email}")
            return jsonify({"message": "Email not found"}), 404
        
        print(f"Email exists: {email}")
        return jsonify({"message": "Email exists"}), 200
    except Exception as e:
        print(f"Error in check-email: {str(e)}")
        current_app.logger.error(f"check-email error: {str(e)}")
        return jsonify({"message": "Internal server error", "error": str(e)}), 500

@auth_bp.route('/request-reset', methods=['POST'])
def request_reset():
    data = request.get_json()
    
    if not data or not data.get('email'):
        return jsonify({"message": "Email is required"}), 400
    
    email = data['email'].lower()
    
    # Validate email format
    if not validate_email(email):
        return jsonify({"message": "Invalid email format"}), 400
    
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
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('verification_code') or not data.get('new_password'):
        return jsonify({"message": "Email, verification code and new password are required"}), 400
    
    email = data['email'].lower()
    verification_code = data['verification_code']
    new_password = data['new_password']
    
    # Validate email format
    if not validate_email(email):
        return jsonify({"message": "Invalid email format"}), 400
    
    # Check if user exists
    user = User.query.filter_by(email=email).first()
    
    if not user:
        return jsonify({"message": "Email not found"}), 404
      # Verify the code
    try:
        print(f"Attempting to verify code: '{verification_code}' for email: '{email}'")
        is_valid = verify_code(email, verification_code)
        print(f"Code verification result: {is_valid}")
        
        if not is_valid:
            return jsonify({"message": "Invalid or expired verification code"}), 400
        
        # Update password
        hashed_password = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        user.password = hashed_password
        db.session.commit()
        
        # Clear the verification code after successful reset
        clear_verification_code(email)
        print(f"Password reset successful for email: {email}")
        
        return jsonify({"message": "Password reset successful"}), 200
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Password reset error: {str(e)}")
        return jsonify({"message": "Error resetting password"}), 500
