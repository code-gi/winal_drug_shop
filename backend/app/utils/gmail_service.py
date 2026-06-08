import os
import base64
import json
import logging
import pickle
import random
import string
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
from flask import current_app
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

logger = logging.getLogger(__name__)

# If modifying these SCOPES, delete the token.pickle file
SCOPES = ['https://www.googleapis.com/auth/gmail.send']

# Dictionary to store verification codes (in production, use database)
verification_codes = {}

# Email configuration
FROM_EMAIL = os.getenv('GMAIL_SENDER', 'astrondaniel6@gmail.com')
FROM_NAME = os.getenv('GMAIL_SENDER_NAME', 'Winal Drug Shop')

# Environment variables
CREDENTIALS_PATH = os.getenv('GMAIL_CREDENTIALS_PATH', 'credentials.json')
TOKEN_PATH = os.getenv('GMAIL_TOKEN_PATH', 'token.json')

# Allow for credentials to be stored directly in environment variables
GMAIL_CREDENTIALS_JSON = os.getenv('GMAIL_CREDENTIALS_JSON')
GMAIL_TOKEN_JSON = os.getenv('GMAIL_TOKEN_JSON')

def get_gmail_service():
    """
    Get an authenticated Gmail API service instance.
    
    Returns:
        service: An authenticated Gmail API service object or None if authentication fails
    """
    creds = None
    
    try:
        # First try to load credentials from environment variables
        if GMAIL_TOKEN_JSON:
            try:
                logger.info("Attempting to load token from GMAIL_TOKEN_JSON environment variable")
                token_data = json.loads(GMAIL_TOKEN_JSON)
                creds = Credentials.from_authorized_user_info(token_data, SCOPES)
            except Exception as e:
                logger.error(f"Error loading token from environment variable: {e}")
        
        # If not available or invalid, load from file
        if not creds and os.path.exists(TOKEN_PATH):
            with open(TOKEN_PATH, 'r') as token:
                creds = Credentials.from_authorized_user_info(eval(token.read()), SCOPES)
        
        # If credentials don't exist or are invalid
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                # Try to load credentials from environment variable
                if GMAIL_CREDENTIALS_JSON:
                    try:
                        logger.info("Loading credentials from GMAIL_CREDENTIALS_JSON environment variable")
                        credentials_data = json.loads(GMAIL_CREDENTIALS_JSON)
                        flow = InstalledAppFlow.from_client_config(credentials_data, SCOPES)
                        creds = flow.run_local_server(port=0)
                    except Exception as e:
                        logger.error(f"Error loading credentials from environment variable: {e}")
                        
                # If environment variable approach failed or not configured, use file
                if not creds and os.path.exists(CREDENTIALS_PATH):
                    logger.info(f"Loading credentials from file: {CREDENTIALS_PATH}")
                    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
                    creds = flow.run_local_server(port=0)
                elif not creds:
                    logger.error(f"No credentials available. Either set GMAIL_CREDENTIALS_JSON environment variable or ensure {CREDENTIALS_PATH} exists")
                    return None
            
            # Save the credentials for next run
            # Save to environment variable if configured to use that
            if GMAIL_TOKEN_JSON is not None:
                os.environ['GMAIL_TOKEN_JSON'] = creds.to_json()
                logger.info("Updated GMAIL_TOKEN_JSON environment variable with new token")
            
            # Also save to file as backup
            with open(TOKEN_PATH, 'wb') as token:
                pickle.dump(creds, token)
        
        # Build Gmail service
        service = build('gmail', 'v1', credentials=creds)
        return service
        
    except Exception as e:
        logger.error(f"Error authenticating with Gmail API: {e}")
        return None

def generate_verification_code(length=6):
    """Generate a random verification code"""
    return ''.join(random.choices(string.digits, k=length))

def store_verification_code(email, code, expiry_minutes=15):
    """Store verification code with expiration"""
    try:
        # Calculate expiration time
        expiry_time = datetime.utcnow() + timedelta(minutes=expiry_minutes)
        
        # Store code with expiry
        verification_codes[email] = {
            'code': code,
            'expires_at': expiry_time
        }
        
        # Print for debugging
        print(f"Stored verification code for {email}: {code}, expires at {expiry_time}")
        return True
    except Exception as e:
        print(f"Error storing verification code: {str(e)}")
        if hasattr(current_app, 'logger'):
            current_app.logger.error(f"Error storing verification code: {str(e)}")
        return False

def verify_code(email, code):
    """Verify a code for an email"""
    if email not in verification_codes:
        return False
        
    stored_data = verification_codes[email]
    if stored_data['expires_at'] < datetime.utcnow():
        # Code has expired
        del verification_codes[email]
        return False
        
    if stored_data['code'] != code:
        return False
        
    return True

def clear_verification_code(email):
    """Clear a verification code after use"""
    if email in verification_codes:
        del verification_codes[email]
        
def send_email(to, subject, html_content, text_content=None):
    """Send an email using Gmail API"""
    try:
        # Get Gmail service
        service = get_gmail_service()
        if not service:
            print("Failed to get Gmail service")
            return False
            
        # Create message
        message = MIMEMultipart('alternative')
        message['to'] = to
        message['subject'] = subject
        
        # Set From header with name and email
        message['from'] = f"{FROM_NAME} <{FROM_EMAIL}>"
        
        # Attach parts
        if text_content:
            part1 = MIMEText(text_content, 'plain')
            message.attach(part1)
            
        part2 = MIMEText(html_content, 'html')
        message.attach(part2)
        
        # Encode message
        raw_message = base64.urlsafe_b64encode(message.as_bytes()).decode()
        
        # Send message
        try:
            message = service.users().messages().send(
                userId='me', body={'raw': raw_message}).execute()
            print(f"Email sent to {to}, message ID: {message.get('id')}")
            return True
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            if hasattr(current_app, 'logger'):
                current_app.logger.error(f"Error sending email: {str(e)}")
            
            # For development, log the email content
            print("\n=== EMAIL (GMAIL ERROR) ===")
            print(f"To: {to}")
            print(f"Subject: {subject}")
            print("====================================\n")
            return False
            
    except Exception as e:
        print(f"Error in send_email: {str(e)}")
        if hasattr(current_app, 'logger'):
            current_app.logger.error(f"Error in send_email: {str(e)}")
        return False

def send_password_reset_email(email, name=None):
    """Send password reset email with verification code"""
    try:
        # Generate verification code
        code = generate_verification_code()
        print(f"Generated verification code for {email}: {code}")
        
        # Store in memory dictionary
        if not store_verification_code(email, code):
            error_msg = "Failed to store verification code"
            print(error_msg)
            raise Exception(error_msg)
        
        # Format name
        user_name = name if name else "Valued Customer"
        
        # Create email content
        html_content = f"""
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
          <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #2196F3;">Winal Drug Shop</h2>
          </div>
          <div>
            <h3>Password Reset</h3>
            <p>Dear {user_name},</p>
            <p>You requested a password reset for your Winal Drug Shop account.</p>
            <p>Your verification code is:</p>
            <div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 24px; letter-spacing: 5px; border-radius: 5px; margin: 20px 0;">
              <strong>{code}</strong>
            </div>
            <p>This code will expire in 15 minutes.</p>
            <p>If you did not request a password reset, please ignore this email or contact our support team if you have concerns.</p>
            <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;">
            <p style="font-size: 12px; color: #757575; text-align: center;">
              &copy; {datetime.now().year} Winal Drug Shop. All rights reserved.
            </p>
          </div>
        </div>
        """
        
        plain_content = f"""
        Password Reset - Winal Drug Shop
        
        Dear {user_name},
        
        You requested a password reset for your Winal Drug Shop account.
        
        Your verification code is: {code}
        
        This code will expire in 15 minutes.
        
        If you did not request a password reset, please ignore this email or contact our support team if you have concerns.
        
        © {datetime.now().year} Winal Drug Shop. All rights reserved.
        """
        
        # If we're in development or testing mode, just print the email
        if os.environ.get('FLASK_ENV') == 'development' or os.environ.get('TESTING'):
            print("\n=== PASSWORD RESET EMAIL (DEV MODE) ===")
            print(f"To: {email}")
            print(f"Subject: Password Reset - Winal Drug Shop")
            print(f"Verification Code: {code}")
            print("====================================\n")
            return True
        
        # Send email
        return send_email(
            to=email,
            subject="Password Reset - Winal Drug Shop",
            html_content=html_content,
            text_content=plain_content
        )
        
    except Exception as e:
        print(f"Global error in send_password_reset_email: {str(e)}")
        if hasattr(current_app, 'logger'):
            current_app.logger.error(f"Global error in send_password_reset_email: {str(e)}")
        return False

def send_welcome_email(email, name):
    """Send welcome email to newly registered user"""
    # Format name
    user_name = name if name else "Valued Customer"
    
    # Create email content
    html_content = f"""
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
      <div style="text-align: center; margin-bottom: 20px;">
        <h2 style="color: #2196F3;">Winal Drug Shop</h2>
      </div>
      <div>
        <h3>Welcome to Winal Drug Shop!</h3>
        <p>Dear {user_name},</p>
        <p>Thank you for registering with Winal Drug Shop! Your account has been successfully created.</p>
        <p>With your new account, you can:</p>
        <ul>
          <li>Browse our wide range of animal and human medications</li>
          <li>Book appointments for farm activities and consultations</li>
          <li>Track your orders and prescription history</li>
          <li>Access exclusive health tips and resources</li>
        </ul>
        <p>If you have any questions or need assistance, please don't hesitate to contact us.</p>
        <p>Best regards,<br>The Winal Drug Shop Team</p>
        <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;">
        <p style="font-size: 12px; color: #757575; text-align: center;">
          &copy; {datetime.now().year} Winal Drug Shop. All rights reserved.
        </p>
      </div>
    </div>
    """
    
    plain_content = f"""
    Welcome to Winal Drug Shop!
    
    Dear {user_name},
    
    Thank you for registering with Winal Drug Shop! Your account has been successfully created.
    
    With your new account, you can:
    • Browse our wide range of animal and human medications
    • Book appointments for farm activities and consultations
    • Track your orders and prescription history
    • Access exclusive health tips and resources
    
    If you have any questions or need assistance, please don't hesitate to contact us.
    
    Best regards,
    The Winal Drug Shop Team
    
    © {datetime.now().year} Winal Drug Shop. All rights reserved.
    """
    
    # If we're in development or testing mode, just print the email
    if os.environ.get('FLASK_ENV') == 'development' or os.environ.get('TESTING'):
        print("\n=== WELCOME EMAIL (DEV MODE) ===")
        print(f"To: {email}")
        print(f"Subject: Welcome to Winal Drug Shop!")
        print("====================================\n")
        return True
    
    # Send email
    return send_email(
        to=email,
        subject="Welcome to Winal Drug Shop!",
        html_content=html_content,
        text_content=plain_content
    )

def send_order_confirmation(email, order_details):
    """
    Send an order confirmation email to the customer
    
    Args:
        email (str): Customer's email address
        order_details (dict): Dictionary containing order information including:
            - customer_name: Name of the customer
            - order_id: Unique order identifier
            - total: Total amount of the order
            - date: Order date
            - items: List of items in the order
            
    Returns:
        bool: True if email was sent successfully, False otherwise
    """
    try:
        # Extract data from order details
        customer_name = order_details.get('customer_name', 'Valued Customer')
        order_id = order_details.get('order_id', 'Unknown')
        total = order_details.get('total', 0.00)
        order_date = order_details.get('date', datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        items = order_details.get('items', [])
        
        # Build items HTML table
        items_html = ""
        items_text = ""
        
        for item in items:
            name = item.get('name', 'Unknown item')
            quantity = item.get('quantity', 1)
            price = item.get('price', 0.00)
            item_total = price * quantity
            
            items_html += f"""
            <tr>
                <td style="padding: 8px; border-bottom: 1px solid #e0e0e0;">{name}</td>
                <td style="padding: 8px; border-bottom: 1px solid #e0e0e0; text-align: center;">{quantity}</td>
                <td style="padding: 8px; border-bottom: 1px solid #e0e0e0; text-align: right;">${price:.2f}</td>
                <td style="padding: 8px; border-bottom: 1px solid #e0e0e0; text-align: right;">${item_total:.2f}</td>
            </tr>
            """
            
            items_text += f"- {name} (Qty: {quantity}) @ ${price:.2f} each = ${item_total:.2f}\n"
        
        # Create HTML email content
        html_content = f"""
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <div style="text-align: center; margin-bottom: 20px;">
                <h2 style="color: #2196F3;">Winal Drug Shop</h2>
                <h3>Order Confirmation</h3>
            </div>
            
            <div>
                <p>Dear {customer_name},</p>
                <p>Thank you for your order. Below are your order details:</p>
                
                <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 15px 0;">
                    <p><strong>Order ID:</strong> {order_id}</p>
                    <p><strong>Date:</strong> {order_date}</p>
                </div>
                
                <h4>Order Summary</h4>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background-color: #f5f5f5;">
                            <th style="padding: 8px; text-align: left; border-bottom: 2px solid #e0e0e0;">Item</th>
                            <th style="padding: 8px; text-align: center; border-bottom: 2px solid #e0e0e0;">Quantity</th>
                            <th style="padding: 8px; text-align: right; border-bottom: 2px solid #e0e0e0;">Price</th>
                            <th style="padding: 8px; text-align: right; border-bottom: 2px solid #e0e0e0;">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items_html}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="3" style="padding: 8px; text-align: right; border-top: 2px solid #e0e0e0;"><strong>Total:</strong></td>
                            <td style="padding: 8px; text-align: right; border-top: 2px solid #e0e0e0;"><strong>${total:.2f}</strong></td>
                        </tr>
                    </tfoot>
                </table>
                
                <p style="margin-top: 20px;">If you have any questions about your order, please contact us.</p>
                <p>Thank you for shopping with Winal Drug Shop!</p>
                <p>Best regards,<br>The Winal Drug Shop Team</p>
                
                <hr style="margin: 20px 0; border: none; border-top: 1px solid #e0e0e0;">
                <p style="font-size: 12px; color: #757575; text-align: center;">
                    &copy; {datetime.now().year} Winal Drug Shop. All rights reserved.
                </p>
            </div>
        </div>
        """
        
        # Create plain text content as fallback
        plain_content = f"""
        Winal Drug Shop - Order Confirmation
        
        Dear {customer_name},
        
        Thank you for your order. Below are your order details:
        
        Order ID: {order_id}
        Date: {order_date}
        
        Order Summary:
        {items_text}
        
        Total: ${total:.2f}
        
        If you have any questions about your order, please contact us.
        
        Thank you for shopping with Winal Drug Shop!
        
        Best regards,
        The Winal Drug Shop Team
        
        © {datetime.now().year} Winal Drug Shop. All rights reserved.
        """
        
        # If in development mode, just print the email
        if os.environ.get('FLASK_ENV') == 'development' or os.environ.get('TESTING'):
            print("\n=== ORDER CONFIRMATION EMAIL (DEV MODE) ===")
            print(f"To: {email}")
            print(f"Subject: Order Confirmation - #{order_id}")
            print(f"Order Total: ${total:.2f}")
            print("=======================================\n")
            return True
        
        # Send the actual email
        return send_email(
            to=email,
            subject=f"Winal Drug Shop - Order Confirmation #{order_id}",
            html_content=html_content,
            text_content=plain_content
        )
        
    except Exception as e:
        logger.error(f"Error sending order confirmation email: {e}")
        if hasattr(current_app, 'logger'):
            current_app.logger.error(f"Error sending order confirmation email: {e}")
        return False 