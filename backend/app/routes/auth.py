from flask import Blueprint, request, jsonify
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
