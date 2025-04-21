# Gmail API Setup Guide

This guide will help you set up the Gmail API for sending emails from your Winal Drug Shop application.

## Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click on "Select a project" in the top navigation bar
3. Click "NEW PROJECT" in the window that appears
4. Name your project (e.g., "Winal Drug Shop") and click "CREATE"
5. Make sure your new project is selected in the top navigation bar

## Step 2: Enable the Gmail API

1. In the Google Cloud Console, navigate to "APIs & Services" > "Library"
2. Search for "Gmail API" and click on it
3. Click "ENABLE" to enable the Gmail API for your project

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Select "External" as the User Type and click "CREATE"
3. Fill in the required fields:
   - App name: "Winal Drug Shop"
   - User support email: Your email address
   - Developer contact information: Your email address
4. Click "SAVE AND CONTINUE"
5. On the Scopes screen, click "ADD OR REMOVE SCOPES"
6. Add the `https://www.googleapis.com/auth/gmail.send` scope
7. Click "UPDATE" and then "SAVE AND CONTINUE"
8. Add test users (your email and any other admin emails)
9. Click "SAVE AND CONTINUE" and then "BACK TO DASHBOARD"

## Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "CREATE CREDENTIALS" and select "OAuth client ID"
3. Select "Desktop application" as the Application type
4. Name it "Winal Drug Shop Desktop Client"
5. Click "CREATE"
6. You'll see a modal with your client ID and client secret - click "DOWNLOAD JSON"
7. Rename the downloaded file to `credentials.json` and place it in your backend directory (same level as your app.py file)

## Step 5: First-time Authorization

The first time you run the application and it tries to send an email, it will:

1. Open a browser window asking you to sign in to your Google account
2. Ask for permission to send emails on your behalf
3. After you grant permission, it will create a `token.pickle` file in your backend directory

This token will be used for future authentication and you won't need to sign in again unless the token expires or is deleted.

## Troubleshooting

- If you get an error about credentials not being valid, check that the `credentials.json` file is in the correct location
- If you get an error about permissions, make sure you've enabled the Gmail API and configured the OAuth consent screen correctly
- If the application can't open a browser window for authentication, you may need to run it in an environment where a browser is available

## Security Notes

- Keep your `credentials.json` and `token.pickle` files secure and never commit them to version control
- In production, store these files in a secure location accessible only by the application
- For enhanced security, consider using a service account instead of OAuth 2.0 client ID, which requires additional setup 