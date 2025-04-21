from flask import Blueprint, request, jsonify, current_app
from app.utils.email_service import send_welcome_email, send_password_reset_email
from app.utils.validation import validate_email

notifications_bp = Blueprint('notifications', __name__)

@notifications_bp.route('/welcome-email', methods=['POST'])
def send_welcome():
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('name'):
        return jsonify({"message": "Email and name are required"}), 400
    
    email = data['email']
    name = data['name']
    
    # Validate email
    if not validate_email(email):
        return jsonify({"message": "Invalid email format"}), 400
    
    try:
        send_welcome_email(email, name)
        return jsonify({"message": "Welcome email sent successfully"}), 200
    except Exception as e:
        current_app.logger.error(f"Error sending welcome email: {str(e)}")
        return jsonify({"message": "Failed to send welcome email"}), 500

@notifications_bp.route('/password-reset', methods=['POST'])
def send_reset():
    data = request.get_json()
    
    if not data or not data.get('email'):
        return jsonify({"message": "Email is required"}), 400
    
    email = data['email']
    
    # Validate email
    if not validate_email(email):
        return jsonify({"message": "Invalid email format"}), 400
    
    try:
        send_password_reset_email(email)
        return jsonify({"message": "Password reset email sent successfully"}), 200
    except Exception as e:
        current_app.logger.error(f"Error sending password reset email: {str(e)}")
        return jsonify({"message": "Failed to send password reset email"}), 500 