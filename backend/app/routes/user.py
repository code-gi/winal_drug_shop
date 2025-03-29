from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import User
from app.schemas import UserSchema
from app.utils import validate_data

user_bp = Blueprint('user', __name__)

@user_bp.route('/me', methods=['GET'])
@jwt_required()
def get_user_profile():
    """Get current user profile"""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    return jsonify(user.to_dict()), 200


@user_bp.route('/me', methods=['PUT'])
@jwt_required()
def update_user_profile():
    """Update current user profile"""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    data = request.get_json()
    
    # Only these fields can be updated
    allowed_fields = {'first_name', 'last_name'}
    update_data = {k: v for k, v in data.items() if k in allowed_fields}
    
    # Validate data
    validated_data, errors = validate_data(update_data, UserSchema(partial=True))
    if errors:
        return errors
    
    # Update user
    try:
        for key, value in validated_data.items():
            setattr(user, key, value)
        
        db.session.commit()
        return jsonify({
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Error: {str(e)}'}), 500