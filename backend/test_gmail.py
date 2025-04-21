#!/usr/bin/env python3

import os
import sys
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import dotenv

# Load environment variables
dotenv.load_dotenv()

# Gmail API setup
SCOPES = ['https://www.googleapis.com/auth/gmail.send']
SENDER_EMAIL = os.getenv('GMAIL_SENDER')
SENDER_NAME = os.getenv('GMAIL_SENDER_NAME', 'Winal Drug Shop')

def get_gmail_service():
    """Get authenticated Gmail API service."""
    creds = None
    # The file token.json stores the user's access and refresh tokens
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_info(
            eval(open('token.json', 'r').read()), SCOPES)
    
    # If there are no valid credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(str(creds.to_json()))
    
    service = build('gmail', 'v1', credentials=creds)
    return service

def create_message(sender_email, sender_name, to, subject, html_content, text_content=None):
    """Create an email message."""
    message = MIMEMultipart('alternative')
    message['to'] = to
    message['from'] = f"{sender_name} <{sender_email}>"
    message['subject'] = subject
    
    # Text part
    if text_content:
        text_part = MIMEText(text_content, 'plain')
        message.attach(text_part)
    
    # HTML part
    html_part = MIMEText(html_content, 'html')
    message.attach(html_part)
    
    # Encode the message
    raw_message = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')
    return {'raw': raw_message}

def send_email(service, message):
    """Send an email message."""
    try:
        sent_message = service.users().messages().send(
            userId='me', body=message).execute()
        print(f"Message sent. Message ID: {sent_message['id']}")
        return sent_message
    except HttpError as error:
        print(f"An error occurred: {error}")
        return None

def main():
    # Check command line arguments
    if len(sys.argv) < 2:
        print("Usage: python test_gmail.py recipient@example.com")
        sys.exit(1)
    
    recipient = sys.argv[1]
    
    # Check environment variables
    if not SENDER_EMAIL:
        print("Error: GMAIL_SENDER environment variable is not set.")
        print("Please add it to your .env file.")
        sys.exit(1)
    
    try:
        # Get Gmail service
        service = get_gmail_service()
        
        # Create test email
        html_content = """
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0;">
                <h1 style="color: #4285F4;">Winal Drug Shop</h1>
            </div>
            <div style="padding: 20px 0;">
                <h2>Test Email</h2>
                <p>This is a test email from the Winal Drug Shop application to verify that the Gmail API integration is working correctly.</p>
                <p>If you're receiving this email, it means that:</p>
                <ul>
                    <li>Your Gmail API credentials are set up correctly</li>
                    <li>The application has the necessary permissions</li>
                    <li>The email sending functionality is working as expected</li>
                </ul>
            </div>
            <div style="padding-top: 20px; border-top: 1px solid #e0e0e0; text-align: center; color: #757575; font-size: 12px;">
                <p>This is an automated message, please do not reply.</p>
                <p>&copy; 2023 Winal Drug Shop. All rights reserved.</p>
            </div>
        </div>
        """
        
        text_content = """
        Winal Drug Shop
        
        Test Email
        
        This is a test email from the Winal Drug Shop application to verify that the Gmail API integration is working correctly.
        
        If you're receiving this email, it means that:
        - Your Gmail API credentials are set up correctly
        - The application has the necessary permissions
        - The email sending functionality is working as expected
        
        This is an automated message, please do not reply.
        © 2023 Winal Drug Shop. All rights reserved.
        """
        
        message = create_message(
            SENDER_EMAIL, 
            SENDER_NAME, 
            recipient, 
            "Winal Drug Shop - Test Email", 
            html_content,
            text_content
        )
        
        # Send email
        print(f"Sending test email to {recipient}...")
        send_email(service, message)
        print("Test completed successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main() 