from marshmallow import Schema, fields, validate, ValidationError, validates_schema
from datetime import datetime
import re

class UserSchema(Schema):
    """Schema for User model serialization/deserialization"""
    id = fields.Int(dump_only=True)
    email = fields.Email(
        required=True,
        error_messages={
            'required': 'Email is required',
            'invalid': 'Please enter a valid email address'
        }
    )
    password = fields.Str(
        required=True, 
        load_only=True,
        error_messages={
            'required': 'Password is required'
        }
    )
    first_name = fields.Str(
        required=True, 
        validate=validate.Length(min=1, error="First name cannot be empty"),
        error_messages={
            'required': 'First name is required'
        }
    )
    last_name = fields.Str(
        required=True, 
        validate=validate.Length(min=1, error="Last name cannot be empty"),
        error_messages={
            'required': 'Last name is required'
        }
    )
    phone_number = fields.Str(
        required=False,
        validate=validate.Regexp(
            r'^\+?\d{10,15}$',
            error="Phone number must be at least 10 digits"
        ),
        error_messages={
            'invalid': 'Phone number must be at least 10 digits'
        }
    )
    date_of_birth = fields.Date(
        required=False, 
        format='%Y-%m-%d',
        error_messages={
            'invalid': 'Date of birth must be in YYYY-MM-DD format'
        }
    )
    is_admin = fields.Bool(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)

    @validates_schema
    def validate_user_data(self, data, **kwargs):
        """Additional validation for user data"""
        errors = {}
        
        # Validate password complexity if password is provided
        if 'password' in data:
            password = data['password']
            password_errors = []
            if len(password) < 8:
                password_errors.append('Password must be at least 8 characters long')
            if not re.search(r'[a-z]', password):
                password_errors.append('Password must contain at least one lowercase letter')
            if not re.search(r'[A-Z]', password):
                password_errors.append('Password must contain at least one uppercase letter')
            if not re.search(r'\d', password):
                password_errors.append('Password must contain at least one number')
            if password_errors:
                errors['password'] = password_errors
        
        # Validate date of birth (must be in the past)
        if 'date_of_birth' in data and data['date_of_birth']:
            if data['date_of_birth'] >= datetime.now().date():
                errors['date_of_birth'] = ['Date of birth must be in the past']
        
        if errors:
            raise ValidationError(errors)

class LoginSchema(Schema):
    """Schema for login data validation"""
    email = fields.Email(
        required=True,
        error_messages={
            'required': 'Email is required',
            'invalid': 'Please enter a valid email address'
        }
    )
    password = fields.Str(
        required=True, 
        load_only=True,
        error_messages={
            'required': 'Password is required'
        }
    )


class PasswordResetRequestSchema(Schema):
    """Schema for password reset request validation"""
    email = fields.Email(
        required=True,
        error_messages={
            'required': 'Email is required',
            'invalid': 'Please enter a valid email address'
        }
    )


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
        ],
        error_messages={
            'required': 'Password is required'
        }
    )
    confirm_password = fields.Str(
        required=True,
        error_messages={
            'required': 'Password confirmation is required'
        }
    )

    @validates_schema
    def validate_password_match(self, data, **kwargs):
        """Validate that passwords match"""
        if 'password' in data and 'confirm_password' in data:
            if data['password'] != data['confirm_password']:
                raise ValidationError({'confirm_password': ['Passwords do not match']})
        return data


class PasswordResetWithCodeSchema(Schema):
    """Schema for password reset with verification code validation"""
    email = fields.Email(
        required=True,
        error_messages={
            'required': 'Email is required',
            'invalid': 'Please enter a valid email address'
        }
    )
    verification_code = fields.Str(
        required=True,
        validate=validate.Length(min=1, error="Verification code cannot be empty"),
        error_messages={
            'required': 'Verification code is required'
        }
    )
    new_password = fields.Str(
        required=True,
        validate=[
            validate.Length(min=8, error="Password must be at least 8 characters long"),
            validate.Regexp(
                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)",
                error="Password must contain at least one uppercase letter, one lowercase letter, and one number"
            )
        ],
        error_messages={
            'required': 'New password is required'
        }
    )

    @validates_schema
    def validate_reset_data(self, data, **kwargs):
        """Additional validation for password reset data"""
        errors = {}
        
        # Validate new password complexity
        if 'new_password' in data:
            password = data['new_password']
            if len(password) < 8:
                errors['new_password'] = ['Password must be at least 8 characters long']
            elif not re.search(r'[a-z]', password):
                errors['new_password'] = ['Password must contain at least one lowercase letter']
            elif not re.search(r'[A-Z]', password):
                errors['new_password'] = ['Password must contain at least one uppercase letter']
            elif not re.search(r'\d', password):
                errors['new_password'] = ['Password must contain at least one number']
        
        if errors:
            raise ValidationError(errors)
