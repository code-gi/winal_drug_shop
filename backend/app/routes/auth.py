from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
    get_jwt
)
from app.models.user import User
from datetime import datetime, timedelta, timezone

auth_bp = Blueprint('auth', __name__)

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
    
    # Generate tokens with extended expiration for admin users
    expires_delta = timedelta(days=7) if user.is_admin else timedelta(hours=1)
    
    access_token = create_access_token(
        identity=user.id,
        expires_delta=expires_delta
    )
    refresh_token = create_refresh_token(identity=user.id)
    
    return jsonify({
        'message': 'Login successful',
        'access_token': access_token,
        'refresh_token': refresh_token,
        'user': user.to_dict()
    }), 200

@auth_bp.route('/token-debug', methods=['GET'])
@jwt_required()
def debug_token():
    """Debug endpoint to check token validity and expiration"""
    user_id = get_jwt_identity()
    jwt_data = get_jwt()
    
    # Get expiration time
    exp_timestamp = jwt_data['exp']
    exp_datetime = datetime.fromtimestamp(exp_timestamp, timezone.utc)
    now = datetime.now(timezone.utc)
    
    # Calculate time until expiration
    time_until_exp = exp_datetime - now
    
    return jsonify({
        'valid': True,
        'user_id': user_id,
        'expires_in_seconds': time_until_exp.total_seconds(),
        'expires_at': exp_datetime.isoformat(),
    }), 200

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
