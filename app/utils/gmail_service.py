import os
import base64
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

logger = logging.getLogger(__name__)

# Gmail API scopes
SCOPES = ['https://www.googleapis.com/auth/gmail.send']

# Environment variables
SENDER_EMAIL = os.getenv('GMAIL_SENDER')
SENDER_NAME = os.getenv('GMAIL_SENDER_NAME', 'Winal Drug Shop')
CREDENTIALS_PATH = os.getenv('GMAIL_CREDENTIALS_PATH', 'credentials.json')
TOKEN_PATH = os.getenv('GMAIL_TOKEN_PATH', 'token.json')

def get_gmail_service():
    """
    Get an authenticated Gmail API service instance.
    
    Returns:
        service: An authenticated Gmail API service object or None if authentication fails
    """
    creds = None
    
    try:
        # Load credentials from the saved token.json file if it exists
        if os.path.exists(TOKEN_PATH):
            with open(TOKEN_PATH, 'r') as token:
                creds = Credentials.from_authorized_user_info(eval(token.read()), SCOPES)
        
        # If no valid credentials available, let the user log in
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                if not os.path.exists(CREDENTIALS_PATH):
                    logger.error(f"Credentials file not found at {CREDENTIALS_PATH}")
                    return None
                    
                flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
                creds = flow.run_local_server(port=0)
            
            # Save the credentials for the next run
            with open(TOKEN_PATH, 'w') as token:
                token.write(str(creds.to_json()))
        
        # Build and return the Gmail service
        service = build('gmail', 'v1', credentials=creds)
        return service
        
    except Exception as e:
        logger.error(f"Error authenticating with Gmail API: {e}")
        return None

def create_message(to, subject, html_content, text_content=None, sender_email=None, sender_name=None):
    """
    Create an email message for the Gmail API.
    
    Args:
        to (str): Recipient email address
        subject (str): Email subject
        html_content (str): HTML content of the email
        text_content (str, optional): Plain text content of the email
        sender_email (str, optional): Override default sender email
        sender_name (str, optional): Override default sender name
    
    Returns:
        dict: A message object for the Gmail API
    """
    message = MIMEMultipart('alternative')
    message['to'] = to
    
    # Use provided sender info or fall back to environment variables
    from_email = sender_email or SENDER_EMAIL
    from_name = sender_name or SENDER_NAME
    
    if not from_email:
        logger.error("Sender email not provided and GMAIL_SENDER environment variable not set")
        return None
        
    message['from'] = f"{from_name} <{from_email}>"
    message['subject'] = subject
    
    # Add plain text version if provided
    if text_content:
        part1 = MIMEText(text_content, 'plain')
        message.attach(part1)
    
    # Add HTML version
    part2 = MIMEText(html_content, 'html')
    message.attach(part2)
    
    # Encode the message
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')
    return {'raw': raw}

def send_email(to, subject, html_content, text_content=None, sender_email=None, sender_name=None):
    """
    Send an email using the Gmail API.
    
    Args:
        to (str): Recipient email address
        subject (str): Email subject
        html_content (str): HTML content of the email
        text_content (str, optional): Plain text content of the email
        sender_email (str, optional): Override default sender email
        sender_name (str, optional): Override default sender name
        
    Returns:
        bool: True if the email was sent successfully, False otherwise
    """
    try:
        # Get the Gmail service
        service = get_gmail_service()
        if not service:
            logger.error("Failed to get Gmail service")
            return False
            
        # Create the message
        message = create_message(
            to=to,
            subject=subject,
            html_content=html_content,
            text_content=text_content,
            sender_email=sender_email,
            sender_name=sender_name
        )
        
        if not message:
            logger.error("Failed to create email message")
            return False
            
        # Send the message
        sent_message = service.users().messages().send(userId='me', body=message).execute()
        logger.info(f"Email sent successfully to {to}. Message ID: {sent_message['id']}")
        return True
        
    except HttpError as error:
        logger.error(f"Gmail API error: {error}")
        return False
    except Exception as e:
        logger.error(f"Error sending email: {e}")
        return False

def send_order_confirmation(to, order_details):
    """
    Send an order confirmation email.
    
    Args:
        to (str): Customer email address
        order_details (dict): Order details including:
            - order_id: The order identifier
            - items: List of items purchased
            - total: Total amount paid
            - date: Order date
            - customer_name: Customer's name
            
    Returns:
        bool: True if email was sent successfully, False otherwise
    """
    try:
        # Create the HTML content for the order confirmation
        items_html = ""
        for item in order_details.get('items', []):
            items_html += f"""
            <tr>
                <td style="padding: 10px; border-bottom: 1px solid #e0e0e0;">{item.get('name', 'Unknown')}</td>
                <td style="padding: 10px; border-bottom: 1px solid #e0e0e0;">{item.get('quantity', 0)}</td>
                <td style="padding: 10px; border-bottom: 1px solid #e0e0e0;">${item.get('price', 0.00):.2f}</td>
                <td style="padding: 10px; border-bottom: 1px solid #e0e0e0;">${item.get('total', 0.00):.2f}</td>
            </tr>
            """
            
        html_content = f"""
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0;">
                <h1 style="color: #4285F4;">Winal Drug Shop</h1>
                <h2>Order Confirmation</h2>
            </div>
            
            <div style="padding: 20px 0;">
                <p>Dear {order_details.get('customer_name', 'Valued Customer')},</p>
                <p>Thank you for your order. Your order details are below:</p>
                
                <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <p><strong>Order ID:</strong> {order_details.get('order_id', 'Unknown')}</p>
                    <p><strong>Date:</strong> {order_details.get('date', 'Unknown')}</p>
                    <p><strong>Total Amount:</strong> ${order_details.get('total', 0.00):.2f}</p>
                </div>
                
                <h3>Order Items</h3>
                <table style="width: 100%; border-collapse: collapse;">
                    <tr style="background-color: #f0f0f0;">
                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #e0e0e0;">Item</th>
                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #e0e0e0;">Quantity</th>
                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #e0e0e0;">Price</th>
                        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #e0e0e0;">Total</th>
                    </tr>
                    {items_html}
                </table>
                
                <p style="margin-top: 20px;">If you have any questions about your order, please contact our customer service.</p>
            </div>
            
            <div style="padding-top: 20px; border-top: 1px solid #e0e0e0; text-align: center; color: #757575; font-size: 12px;">
                <p>Thank you for shopping with Winal Drug Shop!</p>
                <p>&copy; 2023 Winal Drug Shop. All rights reserved.</p>
            </div>
        </div>
        """
        
        # Create the plain text version
        text_content = f"""
        Winal Drug Shop - Order Confirmation
        
        Dear {order_details.get('customer_name', 'Valued Customer')},
        
        Thank you for your order. Your order details are below:
        
        Order ID: {order_details.get('order_id', 'Unknown')}
        Date: {order_details.get('date', 'Unknown')}
        Total Amount: ${order_details.get('total', 0.00):.2f}
        
        Order Items:
        """
        
        for item in order_details.get('items', []):
            text_content += f"\n- {item.get('name', 'Unknown')}: {item.get('quantity', 0)} x ${item.get('price', 0.00):.2f} = ${item.get('total', 0.00):.2f}"
        
        text_content += """
        
        If you have any questions about your order, please contact our customer service.
        
        Thank you for shopping with Winal Drug Shop!
        
        © 2023 Winal Drug Shop. All rights reserved.
        """
        
        # Send the email
        return send_email(
            to=to,
            subject=f"Winal Drug Shop - Order Confirmation #{order_details.get('order_id', 'Unknown')}",
            html_content=html_content,
            text_content=text_content
        )
        
    except Exception as e:
        logger.error(f"Error sending order confirmation email: {e}")
        return False 