from flask import Blueprint, request, jsonify, current_app
from app.utils.gmail_service import send_password_reset_email, generate_verification_code, store_verification_code
from app.models.user import User
from app.utils.validation import validate_email

mail_bp = Blueprint('mail', __name__)

@mail_bp.route('/send-reset', methods=['POST', 'OPTIONS'])
def send_reset():
    """Send password reset verification code via email"""
    # Handle preflight request
    if request.method == 'OPTIONS':
        return jsonify({"message": "OK"}), 200
        
    try:
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
            # But log for debugging
            current_app.logger.warning(f"Password reset requested for non-existent email: {email}")
            return jsonify({"message": "If the email exists, a password reset link will be sent"}), 200
        
        # Log password reset attempt
        current_app.logger.info(f"Sending password reset email to {email}")
        
        # Send password reset email and get the generated code
        result = send_password_reset_email(user.email, user.first_name)
        
        # For easier debugging, include the verification code in the response during development
        # In production, this should be removed for security
        from app.utils.gmail_service import verification_codes
        debug_info = {}
        if email in verification_codes and os.environ.get('FLASK_ENV') == 'development':
            debug_info = {"code": verification_codes[email]['code']}
        
        if result:
            return jsonify({
                "message": "Password reset instructions sent",
                **debug_info
            }), 200
        else:
            return jsonify({"message": "Failed to send password reset email"}), 500
    
    except Exception as e:
        current_app.logger.error(f"Error in send_reset: {str(e)}")
        return jsonify({"message": "Internal server error", "error": str(e)}), 500

@mail_bp.route('/verify-code', methods=['POST'])
def verify_reset_code():
    """Verify a password reset code"""
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('code'):
            return jsonify({"message": "Email and verification code are required"}), 400
        
        email = data['email'].lower()
        code = data['code']
        
        # Validate email format
        if not validate_email(email):
            return jsonify({"message": "Invalid email format"}), 400
        
        # Check if user exists
        user = User.query.filter_by(email=email).first()
        
        if not user:
            return jsonify({"message": "Invalid email or verification code"}), 400
        
        # Verify the code
        from app.utils.gmail_service import verify_code
        if verify_code(email, code):
            return jsonify({"message": "Verification successful"}), 200
        else:
            return jsonify({"message": "Invalid or expired verification code"}), 400
    
    except Exception as e:
        current_app.logger.error(f"Error in verify_reset_code: {str(e)}")
        return jsonify({"message": "Internal server error", "error": str(e)}), 500
