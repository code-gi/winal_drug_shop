from marshmallow import Schema, fields, validate, ValidationError
from datetime import datetime

class UserSchema(Schema):
    """Schema for User model serialization/deserialization"""
    id = fields.Int(dump_only=True)
    email = fields.Email(required=True)
    password = fields.Str(
        required=True, 
        load_only=True,
        validate=[
            validate.Length(min=8, error="Password must be at least 8 characters long"),
            validate.Regexp(
                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)",
                error="Password must contain at least one uppercase letter, one lowercase letter, and one number"
            )
        ]
    )
    first_name = fields.Str(required=True, validate=validate.Length(min=1))
    last_name = fields.Str(required=True, validate=validate.Length(min=1))
    phone_number = fields.Str(required=False)
    date_of_birth = fields.Date(required=False, format='%Y-%m-%d')
    is_admin = fields.Bool(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)


class LoginSchema(Schema):
    """Schema for login data validation"""
    email = fields.Email(required=True)
    password = fields.Str(required=True, load_only=True)


class PasswordResetRequestSchema(Schema):
    """Schema for password reset request validation"""
    email = fields.Email(required=True)


class PasswordResetSchema(Schema):
    """Schema for password reset validation"""
    password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, error="Password must be at least 8 characters long"),
            validate.Regexp(
                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)",
                error="Password must contain at least one uppercase letter, one lowercase letter, and one number"
            )
        ]
    )
    confirm_password = fields.Str(required=True)

    def validate_match(self, data, **kwargs):
        if data.get('password') != data.get('confirm_password'):
            raise ValidationError("Passwords do not match")
        return data