from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity, verify_jwt_in_request, get_jwt
from app.models.user import User
from app import db

users_bp = Blueprint('users', __name__)

@users_bp.route('/me', methods=['GET'])
@jwt_required()
def get_profile():
    """Get the current user's profile information"""
    try:
        # Get the user ID from the JWT token
        user_id = get_jwt_identity()
        current_app.logger.info(f"User ID from token: {user_id}")
        
        # Find the user in the database
        user = User.query.filter_by(id=user_id).first()
        if not user and isinstance(user_id, str) and user_id.isdigit():
            # Try with int if string version doesn't work
            user = User.query.filter_by(id=int(user_id)).first()
        
        if not user:
            current_app.logger.error(f"User not found with ID: {user_id}")
            return jsonify({'message': 'User not found'}), 404
          # Return user profile data (excluding password)
        user_data = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone_number': getattr(user, 'phone_number', None),
            'date_of_birth': user.date_of_birth.strftime('%Y-%m-%d') if hasattr(user, 'date_of_birth') and user.date_of_birth else None,
            'created_at': user.created_at.strftime('%Y-%m-%d %H:%M:%S') if hasattr(user, 'created_at') else None,
            'is_admin': user.is_admin  # Add the is_admin flag
        }
        
        return jsonify(user_data), 200
    except Exception as e:
        current_app.logger.error(f"Error in get_profile: {str(e)}")
        return jsonify({'message': f'Error retrieving profile: {str(e)}'}), 500

@users_bp.route('/me/debug', methods=['GET'])
def debug_profile():
    """Debug endpoint for profile issues"""
    try:
        # First check if there's a token but don't enforce it
        token_present = False
        user_id = None
        
        try:
            verify_jwt_in_request(optional=True)
            claims = get_jwt()
            if claims:
                token_present = True
                user_id = get_jwt_identity()
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': 'Token validation failed',
                'error': str(e)
            }), 400
        
        # Return debug info
        return jsonify({
            'token_present': token_present,
            'user_id': user_id,
            'auth_header': request.headers.get('Authorization', 'None'),
            'auth_header_type': type(request.headers.get('Authorization', None)).__name__
        }), 200
    except Exception as e:
        current_app.logger.error(f"Error in debug_profile: {str(e)}")
        return jsonify({'message': f'Error: {str(e)}'}), 500

@users_bp.route('/me', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update the current user's profile information"""
    # Get the user ID from the JWT token
    user_id = get_jwt_identity()
    
    # Find the user in the database
    user = User.query.filter_by(id=user_id).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    # Get data from request
    data = request.get_json()
    
    # Update user fields (only allow updating certain fields)
    if 'first_name' in data:
        user.first_name = data['first_name']
    if 'last_name' in data:
        user.last_name = data['last_name']
    if 'phone_number' in data:
        user.phone_number = data['phone_number']
    
    # Save changes to database
    try:
        db.session.commit()
        
        # Return updated user data
        return jsonify({
            'message': 'Profile updated successfully',
            'user': {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'phone_number': user.phone_number,
                'date_of_birth': user.date_of_birth.strftime('%Y-%m-%d') if user.date_of_birth else None,
                'created_at': user.created_at.strftime('%Y-%m-%d %H:%M:%S')
            }
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Failed to update profile: {str(e)}'}), 400