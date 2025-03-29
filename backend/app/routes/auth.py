from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token, create_refresh_token, 
    jwt_required, get_jwt_identity, get_jwt
)
from app import db
from app.models import User, TokenBlocklist
from email_validator import validate_email, EmailNotValidError
import re

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['email', 'password', 'first_name', 'last_name']
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({'message': f'{field} is required'}), 400
    
    # Validate email format
    try:
        validate_email(data['email'])
    except EmailNotValidError:
        return jsonify({'message': 'Invalid email format'}), 400
    
    # Check if email already exists
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'message': 'Email already registered'}), 409
    
    # Validate password strength
    password = data['password']
    if len(password) < 8:
        return jsonify({'message': 'Password must be at least 8 characters long'}), 400
    
    # Password complexity check (at least one uppercase, one lowercase, one digit)
    if not (re.search(r'[A-Z]', password) and 
            re.search(r'[a-z]', password) and 
            re.search(r'[0-9]', password)):
        return jsonify({
            'message': 'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        }), 400
    
    # Create new user
    try:
        user = User(
            email=data['email'],
            password=data['password'],
            first_name=data['first_name'],
            last_name=data['last_name']
        )
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'message': 'User registered successfully',
            'user': user.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error: {str(e)}'}), 500


@auth_bp.route('/login', methods=['POST'])
def login():
    """Login and receive JWT token"""
    data = request.get_json()
    
    # Validate required fields
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'message': 'Email and password are required'}), 400
    
    # Check user credentials
    user = User.query.filter_by(email=data['email']).first()
    if not user or not user.verify_password(data['password']):
        return jsonify({'message': 'Invalid email or password'}), 401
    
    # Generate tokens
    access_token = create_access_token(identity=user.id)
    refresh_token = create_refresh_token(identity=user.id)
    
    return jsonify({
        'message': 'Login successful',
        'access_token': access_token,
        'refresh_token': refresh_token,
        'user': user.to_dict()
    }), 200


@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """Refresh JWT token"""
    current_user_id = get_jwt_identity()
    access_token = create_access_token(identity=current_user_id)
    
    return jsonify({
        'access_token': access_token
    }), 200


@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """Logout (invalidate token)"""
    jti = get_jwt()['jti']
    token_block = TokenBlocklist(jti=jti)
    
    try:
        db.session.add(token_block)
        db.session.commit()
        return jsonify({'message': 'Successfully logged out'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error: {str(e)}'}), 500


@auth_bp.route('/reset-password', methods=['POST'])
def reset_password_request():
    """Request password reset"""
    data = request.get_json()
    
    # Validate email is provided
    if not data or not data.get('email'):
        return jsonify({'message': 'Email is required'}), 400
    
    # Check if user exists
    user = User.query.filter_by(email=data['email']).first()
    if not user:
        # For security reasons, don't reveal if email exists or not
        return jsonify({'message': 'If your email exists in our system, you will receive a password reset link'}), 200
    
    # In a real application, you would send an email with a reset link
    # For now, we'll just return a success message
    
    return jsonify({
        'message': 'If your email exists in our system, you will receive a password reset link'
    }), 200


@auth_bp.route('/reset-password/<token>', methods=['POST'])
def reset_password(token):
    """Reset password with token"""
    # In a real application, you would validate the token
    # For now, we'll just return a message
    
    data = request.get_json()
    
    # Validate password is provided
    if not data or not data.get('password'):
        return jsonify({'message': 'New password is required'}), 400
    
    # Validate password strength
    password = data['password']
    if len(password) < 8:
        return jsonify({'message': 'Password must be at least 8 characters long'}), 400
    
    # Password complexity check (at least one uppercase, one lowercase, one digit)
    if not (re.search(r'[A-Z]', password) and 
            re.search(r'[a-z]', password) and 
            re.search(r'[0-9]', password)):
        return jsonify({
            'message': 'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        }), 400
    
    # In a real application, you would validate the token and update the user's password
    # For now, we'll just return a success message
    
    return jsonify({
        'message': 'Password has been reset successfully'
    }), 200


@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile information - alternative endpoint for testing"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Find the user in the database
    user = User.query.filter_by(id=user_id).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    # Return user profile data (excluding password)
    return jsonify({
        'id': user.id,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'phone_number': user.phone_number,
        'date_of_birth': user.date_of_birth.strftime('%Y-%m-%d') if user.date_of_birth else None,
        'created_at': user.created_at.strftime('%Y-%m-%d %H:%M:%S')
    }), 200


@auth_bp.route('/token-debug', methods=['GET'])
def token_debug():
    """Endpoint to debug token issues"""
    auth_header = request.headers.get('Authorization', '')
    
    if not auth_header:
        return jsonify({
            'status': 'error',
            'message': 'No Authorization header found',
            'detail': 'Your request is missing the Authorization header'
        }), 400
    
    try:
        parts = auth_header.split()
        if parts[0].lower() != 'bearer':
            return jsonify({
                'status': 'error',
                'message': 'Invalid Authorization format',
                'detail': f'Expected "Bearer <token>" format, got: {parts[0]} ...'
            }), 400
            
        if len(parts) == 1:
            return jsonify({
                'status': 'error',
                'message': 'Token missing',
                'detail': 'Authorization header found but token is missing'
            }), 400
            
        token = parts[1]
        
        # Just return basic token info without validation
        return jsonify({
            'status': 'info',
            'message': 'Token received',
            'token_length': len(token),
            'token_format': 'Appears to be JWT' if token.count('.') == 2 else 'Doesn\'t appear to be a JWT format',
            'token_prefix': token[:10] + '...' if len(token) > 10 else token
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': 'Error analyzing token',
            'detail': str(e)
        }), 500