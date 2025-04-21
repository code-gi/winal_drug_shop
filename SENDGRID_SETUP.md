 # Setting Up SendGrid for Email Integration

This guide explains how to set up SendGrid to send transactional emails from your Winal Drug Shop application.

## Prerequisites

1. A SendGrid account (You can sign up for a free account at [SendGrid](https://sendgrid.com))
2. Access to your application's backend code
3. Access to your application's frontend code

## Step 1: Create a SendGrid Account and API Key

1. Sign up for a SendGrid account at [https://sendgrid.com](https://sendgrid.com)
2. Once logged in, navigate to Settings → API Keys
3. Click "Create API Key"
4. Name your API key (e.g., "Winal Drug Shop Emails")
5. Select "Full Access" or "Restricted Access" with permissions for "Mail Send"
6. Copy the generated API key (you will only see it once)

## Step 2: Verify Your Sender Identity

Before you can send emails, you need to verify your sender identity:

1. In SendGrid, navigate to Settings → Sender Authentication
2. Choose either Domain Authentication (recommended) or Single Sender Verification
3. Follow the prompts to verify your domain or email address

## Step 3: Configure Your Backend

1. In your backend project, create a `.env` file if you don't already have one
2. Add the following environment variables:

```
SENDGRID_API_KEY=your_api_key_here
FROM_EMAIL=your_verified_email@example.com
FROM_NAME=Winal Drug Shop
```

3. Make sure you've installed the SendGrid package in your backend:

```bash
# For Flask backend
pip install sendgrid

# Add to requirements.txt
sendgrid==6.10.0
```

## Step 4: Configure Your Frontend

1. In your Flutter project, make sure you've added the `sendgrid_mailer` package:

```yaml
# In pubspec.yaml
dependencies:
  sendgrid_mailer: ^0.1.3
```

2. Run `flutter pub get` to install the package

## Step 5: Testing Your Integration

1. Test the password reset functionality:
   - Go to the login screen
   - Click on "Forgot Password"
   - Enter your email
   - You should receive a verification code

2. Check for any errors in your console logs

## Troubleshooting

- If emails aren't being delivered, check your SendGrid Activity Feed for any delivery issues
- Ensure your sender email is verified
- Make sure your API key has the correct permissions
- Check that your API key is correctly set in both backend and frontend code
- For local development, make sure you're not blocked by any firewall issues

## Production Considerations

- Always store your API keys securely and never commit them to version control
- Consider using Firebase Remote Config or similar to manage API keys
- Set up SendGrid event webhooks to track email deliveries, opens, and clicks
- Implement proper error handling for email sending failures
- Set up SPF and DKIM records for your domain to improve deliverability

## Additional Resources

- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Flutter SendGrid Mailer Package](https://pub.dev/packages/sendgrid_mailer)
- [Email Deliverability Best Practices](https://sendgrid.com/resource/guide-email-deliverability/)