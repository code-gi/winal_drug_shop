# Gmail API Integration for Winal Drug Shop

This document provides a quick guide on how to use the Gmail API integration in the Winal Drug Shop application.

## Setup

1. Follow the instructions in `GMAIL_SETUP.md` to set up your Gmail API credentials
2. Ensure your `.env` file contains the following variables:
   ```
   GMAIL_SENDER=your-gmail@gmail.com
   GMAIL_SENDER_NAME=Winal Drug Shop
   ```

## Testing the Integration

A test script is provided to verify that your Gmail API integration is working correctly:

```bash
# Run the test script with a recipient email
python backend/test_gmail.py recipient@example.com

# Or run without arguments to use the default recipient
python backend/test_gmail.py
```

## Using in Code

### Sending a Basic Email

```python
from app.utils.gmail_service import send_email

# Send a simple email
success = send_email(
    to="recipient@example.com",
    subject="Your Subject",
    html_content="<p>HTML content here</p>",
    text_content="Plain text version here"
)

if success:
    print("Email sent successfully")
else:
    print("Failed to send email")
```

### Sending a Password Reset Email

```python
from app.utils.gmail_service import send_password_reset_email

# Send a password reset email with verification code
send_password_reset_email(
    to="user@example.com",
    verification_code="123456",
    user_name="John Doe"
)
```

### Verification Code Management

```python
from app.utils.gmail_service import (
    generate_verification_code,
    store_verification_code,
    verify_code,
    clear_verification_code
)

# Generate a new code
code = generate_verification_code()

# Store the code for a specific user
store_verification_code("user@example.com", code)

# Verify a code (returns True/False)
is_valid = verify_code("user@example.com", "123456")

# Clear a stored code
clear_verification_code("user@example.com")
```

## Troubleshooting

1. If you encounter authentication issues, delete the `token.json` file and run the application again to re-authenticate
2. Check the application logs for detailed error messages
3. Verify that your Gmail API is enabled in the Google Cloud Console
4. Ensure your OAuth consent screen is properly configured

## Security Notes

- Never commit your `credentials.json` or `token.json` files to version control
- The Gmail API uses OAuth 2.0 authentication, which is more secure than storing plain email/password credentials
- Verification codes are stored in memory and are not persisted between application restarts 