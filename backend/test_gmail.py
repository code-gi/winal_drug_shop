#!/usr/bin/env python3

import os
import sys
import json
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

# Get credentials paths or direct JSON
CREDENTIALS_PATH = os.getenv('GMAIL_CREDENTIALS_PATH', 'credentials.json')
TOKEN_PATH = os.getenv('GMAIL_TOKEN_PATH', 'token.json')
GMAIL_CREDENTIALS_JSON = os.getenv('GMAIL_CREDENTIALS_JSON')
GMAIL_TOKEN_JSON = os.getenv('GMAIL_TOKEN_JSON')

def get_gmail_service():
    """Get authenticated Gmail API service."""
    creds = None
    
    # First try to load credentials from environment variables
    if GMAIL_TOKEN_JSON:
        try:
            print("Using token from GMAIL_TOKEN_JSON environment variable")
            token_data = json.loads(GMAIL_TOKEN_JSON)
            creds = Credentials.from_authorized_user_info(token_data, SCOPES)
        except Exception as e:
            print(f"Error loading token from environment variable: {e}")
    
    # If no environment variable or it failed, try token file
    if not creds and os.path.exists(TOKEN_PATH):
        print(f"Using token from file: {TOKEN_PATH}")
        try:
            creds = Credentials.from_authorized_user_info(
                eval(open(TOKEN_PATH, 'r').read()), SCOPES)
        except Exception as e:
            print(f"Error loading token from file: {e}")
    
    # If there are no valid credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            print("Refreshing expired token")
            try:
                creds.refresh(Request())
                print("Token refreshed successfully")
            except Exception as e:
                print(f"Error refreshing token: {e}")
                creds = None  # Clear the creds to force new token generation
        
        # If still no valid credentials, initiate the OAuth flow
        if not creds or not creds.valid:
            print("Need to obtain new credentials")
            
            # Try to load credentials from environment variable first
            if GMAIL_CREDENTIALS_JSON:
                try:
                    print("Using credentials from GMAIL_CREDENTIALS_JSON environment variable")
                    credentials_data = json.loads(GMAIL_CREDENTIALS_JSON)
                    flow = InstalledAppFlow.from_client_config(credentials_data, SCOPES)
                    creds = flow.run_local_server(port=0)
                    print("New credentials obtained successfully")
                except Exception as e:
                    print(f"Error loading credentials from environment variable: {e}")
            
            # Fall back to credentials file if environment variable approach failed
            if not creds or not creds.valid:
                if os.path.exists(CREDENTIALS_PATH):
                    print(f"Using credentials from file: {CREDENTIALS_PATH}")
                    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
                    creds = flow.run_local_server(port=0)
                    print("New credentials obtained successfully from file")
                else:
                    print(f"Error: Could not find credentials file at {CREDENTIALS_PATH}")
                    return None
        
        # Save the new credentials for next run
        if creds and creds.valid:
            # Save to environment variable if that's what we're using
            if GMAIL_TOKEN_JSON is not None:
                print("Updating GMAIL_TOKEN_JSON environment variable")
                new_token_json = creds.to_json()
                os.environ['GMAIL_TOKEN_JSON'] = new_token_json
                
                # Print the new token for manual update (in development)
                print("\nNew token generated. Update your .env file with this value:")
                print(f"GMAIL_TOKEN_JSON={new_token_json}\n")
            
            # Also save to file as backup
            print(f"Saving token to file: {TOKEN_PATH}")
            with open(TOKEN_PATH, 'w') as token:
                token.write(str(creds.to_json()))
    
    # Build Gmail service
    if creds and creds.valid:
        service = build('gmail', 'v1', credentials=creds)
        return service
    else:
        print("Failed to obtain valid credentials")
        return None

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

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_gmail.py <recipient_email>")
        sys.exit(1)
    
    recipient = sys.argv[1]
    
    # Create test email
    html_content = """
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
        <div style="text-align: center; margin-bottom: 20px;">
            <h2 style="color: #2196F3;">Winal Drug Shop</h2>
        </div>
        <div>
            <h3>Test Email</h3>
            <p>This is a test email from Winal Drug Shop.</p>
            <p>If you received this email, it means the Gmail API integration is working correctly.</p>
        </div>
    </div>
    """
    
    text_content = """
    Test Email - Winal Drug Shop
    
    This is a test email from Winal Drug Shop.
    
    If you received this email, it means the Gmail API integration is working correctly.
    """
    
    try:
        # Get Gmail service
        service = get_gmail_service()
        if not service:
            print("Failed to get authenticated Gmail service")
            sys.exit(1)
            
        # Create and send message
        print(f"Sending test email to {recipient}...")
        message = create_message(
            SENDER_EMAIL, 
            SENDER_NAME, 
            recipient, 
            "Test Email from Winal Drug Shop", 
            html_content, 
            text_content
        )
        result = send_email(service, message)
        if result:
            print("Test completed successfully!")
        else:
            print("Failed to send email")
            sys.exit(1)
    except Exception as e:
        print(f"Test failed: {e}")
        sys.exit(1) 