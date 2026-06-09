"""
Utility functions for formatting validation errors consistently across the application
"""

def format_validation_errors(validation_errors, field_requirements=None):
    """
    Format Marshmallow validation errors into a user-friendly structure
    
    Args:
        validation_errors (dict): Validation errors from Marshmallow
        field_requirements (dict, optional): Custom field requirement messages
    
    Returns:
        dict: Formatted error response with field-specific details
    """
    
    # Default field requirements
    default_requirements = {
        'email': 'Please enter a valid email address',
        'password': 'Only the missing password requirements are shown',
        'first_name': 'First name is required and cannot be empty',
        'last_name': 'Last name is required and cannot be empty',
        'phone_number': 'Phone number must be at least 10 digits and can start with +',
        'date_of_birth': 'Date of birth must be in YYYY-MM-DD format and in the past',
        'confirm_password': 'Password confirmation must match the password'
    }
    
    # Merge with custom requirements if provided
    if field_requirements:
        default_requirements.update(field_requirements)
    
    formatted_errors = {}
    
    for field, messages in validation_errors.items():
        if isinstance(messages, list):
            formatted_errors[field] = {
                'errors': messages,
                'requirement': default_requirements.get(
                    field, 
                    f'{field.replace("_", " ").title()} is required'
                ),
                'field_name': field.replace('_', ' ').title()
            }
        else:
            formatted_errors[field] = {
                'errors': [messages],
                'requirement': default_requirements.get(
                    field, 
                    f'{field.replace("_", " ").title()} is required'
                ),
                'field_name': field.replace('_', ' ').title()
            }
    
    return {
        'message': 'Validation failed',
        'field_errors': formatted_errors,
        'summary': f'Please fix {len(formatted_errors)} field{"s" if len(formatted_errors) > 1 else ""} with validation errors',
        'total_errors': len(formatted_errors)
    }


def format_single_field_error(field_name, error_message, requirement_message=None):
    """
    Format a single field error
    
    Args:
        field_name (str): Name of the field
        error_message (str): Error message
        requirement_message (str, optional): Requirement message
    
    Returns:
        dict: Formatted error response
    """
    if not requirement_message:
        requirement_message = f'{field_name.replace("_", " ").title()} has an error'
    
    return {
        'message': 'Validation failed',
        'field_errors': {
            field_name: {
                'errors': [error_message],
                'requirement': requirement_message,
                'field_name': field_name.replace('_', ' ').title()
            }
        },
        'summary': f'Please fix the error in {field_name.replace("_", " ").title()}',
        'total_errors': 1
    }


def get_validation_summary(formatted_errors):
    """
    Generate a summary of validation errors
    
    Args:
        formatted_errors (dict): Formatted error structure
    
    Returns:
        str: Human-readable summary
    """
    if not formatted_errors.get('field_errors'):
        return 'No validation errors'
    
    field_names = []
    for field, error_info in formatted_errors['field_errors'].items():
        field_names.append(error_info.get('field_name', field.replace('_', ' ').title()))
    
    if len(field_names) == 1:
        return f'Please fix the error in {field_names[0]}'
    elif len(field_names) == 2:
        return f'Please fix errors in {field_names[0]} and {field_names[1]}'
    else:
        return f'Please fix errors in {", ".join(field_names[:-1])}, and {field_names[-1]}'
