import 'package:flutter/material.dart';
import '../services/email_service.dart';
import 'package:flutter/foundation.dart';

class TestEmailScreen extends StatefulWidget {
  const TestEmailScreen({Key? key}) : super(key: key);

  @override
  State<TestEmailScreen> createState() => _TestEmailScreenState();
}

class _TestEmailScreenState extends State<TestEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isCheckingApiKey = false;
  bool _isSendingEmail = false;
  String _apiKeyResult = '';
  String _emailResult = '';
  bool _isApiKeyValid = false;
  
  // Create an instance of the EmailService
  final EmailService _emailService = EmailService();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    setState(() {
      _isCheckingApiKey = true;
      _apiKeyResult = '';
      _isApiKeyValid = false;
    });

    try {
      final isValid = await _emailService.validateApiKey();

      setState(() {
        if (isValid) {
          _apiKeyResult = 'Gmail API credentials are valid!';
          _isApiKeyValid = true;
        } else {
          _apiKeyResult = 'Gmail API validation failed';
        }
      });
    } catch (e) {
      setState(() {
        _apiKeyResult = 'Error checking Gmail API: $e';
      });
      debugPrint('Error checking Gmail API: $e');
    } finally {
      setState(() {
        _isCheckingApiKey = false;
      });
    }
  }

  Future<void> _sendTestEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailResult = 'Please enter a recipient email';
      });
      return;
    }

    setState(() {
      _isSendingEmail = true;
      _emailResult = '';
    });

    try {
      final recipientName = _nameController.text.isEmpty ? 'Test User' : _nameController.text.trim();
      
      final success = await _emailService.sendTestEmail(
        to: _emailController.text.trim(),
        subject: 'Test Email from Winal Drug Shop',
        content: 'This is a test email from the Winal Drug Shop application.',
      );

      setState(() {
        if (success) {
          _emailResult = 'Test email sent successfully!';
        } else {
          _emailResult = 'Failed to send email';
        }
      });
    } catch (e) {
      setState(() {
        _emailResult = 'Error sending test email: $e';
      });
      debugPrint('Error sending test email: $e');
    } finally {
      setState(() {
        _isSendingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Gmail API Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check Gmail API Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isCheckingApiKey ? null : _checkApiKey,
                      child: _isCheckingApiKey
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Checking...'),
                              ],
                            )
                          : const Text('Check Gmail API'),
                    ),
                    const SizedBox(height: 16),
                    if (_apiKeyResult.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: _isApiKeyValid ? Colors.green.shade100 : Colors.red.shade100,
                        child: Text(
                          _apiKeyResult,
                          style: TextStyle(
                            color: _isApiKeyValid ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Send Test Email Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Test Email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Email',
                        hintText: 'Enter email address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name (Optional)',
                        hintText: 'Enter recipient name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email Configuration (from .env file):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Gmail Sender: Set in GMAIL_SENDER env variable'),
                    const Text('Sender Name: Set in GMAIL_SENDER_NAME env variable'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSendingEmail ? null : _sendTestEmail,
                      child: _isSendingEmail
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Sending...'),
                              ],
                            )
                          : const Text('Send Test Email'),
                    ),
                    const SizedBox(height: 16),
                    if (_emailResult.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: _emailResult.contains('successfully')
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Text(
                          _emailResult,
                          style: TextStyle(
                            color: _emailResult.contains('successfully')
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Troubleshooting Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Troubleshooting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Make sure credentials.json is in the backend directory'),
                    const Text('2. Check that GMAIL_SENDER is set in .env file'),
                    const Text('3. Verify that Gmail API is enabled in Google Cloud Console'),
                    const Text('4. Ensure OAuth consent screen is properly configured'),
                    const Text('5. For detailed error information, check the console logs'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 