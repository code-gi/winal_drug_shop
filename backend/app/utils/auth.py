from functools import wraps
from flask import jsonify
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from functools import wraps
from app.models import User

def token_required(fn):
    """Decorator to verify JWT token and get current user"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        current_user = User.query.get(user_id)
        
        if not current_user:
            return jsonify(message="Invalid token"), 401
            
        return fn(current_user, *args, **kwargs)
    
    return wrapper

def admin_required(fn):
    """Decorator to check if the user is an admin"""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user or not user.is_admin:
            return jsonify(message="Admin privileges required"), 403
        
        return fn(*args, **kwargs)
    
    return wrapper