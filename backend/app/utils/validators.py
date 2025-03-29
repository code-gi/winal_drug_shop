from marshmallow import ValidationError
from flask import jsonify

def validate_data(data, schema, partial=False):
    """
    Validate request data against a marshmallow schema
    
    Args:
        data: The request data to validate
        schema: The marshmallow schema to validate against
        partial: Whether to validate partial data
        
    Returns:
        tuple: (validated_data, None) if valid, (None, error_response) if invalid
    """
    try:
        validated_data = schema.load(data, partial=partial)
        return validated_data, None
    except ValidationError as err:
        error_response = jsonify({"errors": err.messages}), 400
        return None, error_response