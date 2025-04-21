import re

def validate_email(email):
    """
    Validate email format
    Returns True if valid, False otherwise
    """
    # Simple regex pattern for email validation
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def validate_password(password):
    """
    Validate password strength
    Returns True if valid, False otherwise
    """
    # Password must be at least 8 characters
    if len(password) < 8:
        return False
    
    # Additional password strength checks can be added here
    # e.g., requiring uppercase, lowercase, numbers, special characters
    
    return True 