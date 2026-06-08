# Gmail API Setup Guide

This guide will walk you through setting up Gmail API credentials for the Winal Drug Shop application.

## Prerequisites

- A Google account
- Python 3.7 or higher installed
- The Winal Drug Shop application code

## Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click on "Select a project" at the top of the page
3. Click "NEW PROJECT" in the top-right corner
4. Enter "Winal Drug Shop" as the project name
5. Click "CREATE"
6. Wait for the project to be created and select it

## Step 2: Enable the Gmail API

1. In the Google Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Gmail API"
3. Click on "Gmail API" in the search results
4. Click "ENABLE"

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Select "External" for the User Type and click "CREATE"
3. Fill in the application details:
   - App name: Winal Drug Shop
   - User support email: Your email address
   - Developer contact information: Your email address
4. Click "SAVE AND CONTINUE"
5. Under "Scopes", click "ADD OR REMOVE SCOPES"
6. Add the following scopes:
   - `https://www.googleapis.com/auth/gmail.send`
7. Click "SAVE AND CONTINUE"
8. Under "Test users", click "ADD USERS"
9. Add your email address as a test user
10. Click "SAVE AND CONTINUE"
11. Review your settings and click "BACK TO DASHBOARD"

## Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "CREATE CREDENTIALS" > "OAuth client ID"
3. Select "Desktop app" as the Application type
4. Name it "Winal Drug Shop Desktop Client"
5. Click "CREATE"
6. Click "DOWNLOAD JSON" to download your credentials
7. Rename the downloaded file to `credentials.json`

## Step 5: Add Credentials to Your Application

1. Move the `credentials.json` file to the root directory of your application
2. Add the following entry to your `.gitignore` file to ensure credentials aren't committed:
   ```
   credentials.json
   token.json
   ```

## Step 6: Configure Environment Variables

1. Add the following variables to your `.env` file:
   ```
   GMAIL_SENDER=your-gmail@gmail.com
   GMAIL_SENDER_NAME=Winal Drug Shop
   ```

## Step 7: First-time Authentication

The first time you run the application or the test script, it will:

1. Open a browser window asking you to sign in to your Google account
2. Ask you to grant the requested permissions
3. Once you approve, a `token.json` file will be generated in your application directory

This token will be used for all subsequent API calls until it expires.

## Step 8: Test Your Setup

Run the test script to verify your setup:

```bash
python backend/test_gmail.py recipient@example.com
```

If the test is successful, you should receive a test email at the specified address.

## Troubleshooting

- **Authentication Errors**: Delete the `token.json` file and try again
- **API Not Enabled**: Ensure the Gmail API is enabled in your Google Cloud project
- **Scope Issues**: Ensure the correct scope (`https://www.googleapis.com/auth/gmail.send`) is added to your OAuth consent screen
- **Quota Limits**: Gmail API has usage quotas. Check the [Gmail API Quotas](https://developers.google.com/gmail/api/reference/quota) for more information

## Security Considerations

- Keep your `credentials.json` and `token.json` files secure
- Never commit these files to version control
- If you suspect your credentials have been compromised, regenerate them immediately in the Google Cloud Console 