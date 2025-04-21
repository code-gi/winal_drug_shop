import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/email_service.dart';
import '../utils/auth_service.dart';
import '../utils/debug_helper.dart';
import 'dart:developer' as developer;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isEmailSent = false;
  bool isCodeVerified = false;
  String? errorMessage;
  
  // Create instances of services
  final AuthService _authService = AuthService();
  final EmailService _emailService = EmailService();
  
  // Store verification code locally as it's no longer in the old service
  String? _verificationCode;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email address";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('📱 SCREEN DEBUG: Starting password reset for email: $email');
      
      // First check if email exists
      final emailCheckResult = await _authService.requestPasswordReset(email);
      print('📱 SCREEN DEBUG: Email check result: $emailCheckResult');
      
      if (!emailCheckResult['success']) {
        setState(() {
          errorMessage = emailCheckResult['message'] ?? 'Email not found or invalid';
          isLoading = false;
        });
        print('📱 SCREEN DEBUG: Email check failed: $errorMessage');
        return;
      }
      
      // Send password reset email with verification code
      print('📱 SCREEN DEBUG: Email exists, sending verification code');
      
      // Generate a verification code locally (6 digits)
      _verificationCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      print('📱 SCREEN DEBUG: Generated verification code: $_verificationCode');
      
      // Send password reset email
      final result = await _emailService.sendPasswordResetEmail(
        to: email,
        name: null, // No name available in this context
      );
      
      setState(() {
        isLoading = false;
        if (result) {
          isEmailSent = true;
          errorMessage = null;
          print('📱 SCREEN DEBUG: Verification code sent successfully');
          
          // Show the verification code in development mode
          if (_verificationCode != null) {
            DebugHelper.showVerificationCode(context, email, _verificationCode!);
            // Also print in large format for easy viewing
            print('\n\n');
            print('=============================================');
            print('🔑 VERIFICATION CODE FOR $email:');
            print('🔑 $_verificationCode');
            print('=============================================');
            print('\n\n');
          }
          
          // Show debug toast
          DebugHelper.showDebugToast(context, 'Verification code sent. Check console for the code.');
        } else {
          errorMessage = 'Failed to send verification code';
          print('📱 SCREEN DEBUG: Failed to send verification code');
          
          // Even though the email failed, we can still use the local verification code
          print('\n\n');
          print('=============================================');
          print('⚠️ EMAIL FAILED BUT YOU CAN STILL USE THIS CODE:');
          print('🔑 $_verificationCode');
          print('=============================================');
          print('\n\n');
          
          // Show debug toast for error
          DebugHelper.showDebugToast(context, 'Email failed, but you can still use the local verification code. Check console.');
        }
      });
      
    } catch (e) {
      developer.log('Password reset error', error: e);
      print('📱 SCREEN DEBUG: Exception in password reset: ${e.toString()}');
      setState(() {
        errorMessage = 'Network error. Please check your connection and try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = codeController.text.trim();
    final email = emailController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        errorMessage = "Please enter the verification code";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Verify the code against our locally stored code
      print('📱 SCREEN DEBUG: Verifying code: $code for email: $email');
      final isValid = code == _verificationCode;
      print('📱 SCREEN DEBUG: Code verification result: $isValid');
      
      setState(() {
        isLoading = false;
        if (isValid) {
          isCodeVerified = true;
          errorMessage = null;
          print('📱 SCREEN DEBUG: Code verified successfully');
        } else {
          errorMessage = 'Invalid verification code. Please try again.';
          print('📱 SCREEN DEBUG: Invalid verification code');
        }
      });
    } catch (e) {
      print('📱 SCREEN DEBUG: Exception in code verification: ${e.toString()}');
      setState(() {
        errorMessage = 'Failed to verify code. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        errorMessage = "Password must be at least 8 characters long";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('📱 SCREEN DEBUG: Resetting password for email: $email');
      
      // Call the reset password API
      final result = await _authService.resetPassword(
        email: email,
        verificationCode: code,
        newPassword: newPassword,
      );
      
      print('📱 SCREEN DEBUG: Password reset result: $result');
      
      setState(() {
        isLoading = false;
      });
      
      if (result['success']) {
        print('📱 SCREEN DEBUG: Password reset successful');
        
        // Clear the verification code after successful reset
        _verificationCode = null;
        
        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Success"),
              content: const Text("Your password has been reset successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);  // Close dialog
                    Navigator.pop(context);  // Return to login screen
                  },
                  child: const Text("Back to Login"),
                ),
              ],
            ),
          );
        }
      } else {
        print('📱 SCREEN DEBUG: Password reset failed: ${result['message']}');
        setState(() {
          errorMessage = result['message'] ?? 'Failed to reset password. Please try again.';
        });
      }
    } catch (e) {
      print('📱 SCREEN DEBUG: Exception in password reset: ${e.toString()}');
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCodeVerified
                        ? "Create New Password"
                        : isEmailSent
                            ? "Verification Code"
                            : "Reset Password",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  isEmailSent
                      ? (isCodeVerified
                          ? _buildNewPasswordForm()
                          : _buildVerificationForm())
                      : _buildResetForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Forgot your password?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enter the email address associated with your account and we'll send you a verification code to reset your password.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        if (errorMessage != null) const SizedBox(height: 20),
        _buildAnimatedInput(
          controller: emailController,
          labelText: "Email address",
          hintText: "Enter your email address",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _requestPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: Colors.blue.withOpacity(0.4),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Send Verification Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Back to Login",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Verification code sent!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We've sent a 6-digit verification code to ${emailController.text}. The code expires in 15 minutes.",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        if (errorMessage != null) const SizedBox(height: 20),
        _buildAnimatedInput(
          controller: codeController,
          labelText: "Verification Code",
          hintText: "Enter 6-digit code",
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: Colors.blue.withOpacity(0.4),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Verify Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Reset state to go back to email form
                setState(() {
                  isEmailSent = false;
                  isCodeVerified = false;
                  errorMessage = null;
                });
              },
              child: const Text(
                "Change Email",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : _requestPasswordReset,
              child: const Text(
                "Resend Code",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security, color: Colors.amber[800], size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create a new password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your new password must be different from previously used passwords and contain at least 8 characters.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        if (errorMessage != null) const SizedBox(height: 20),
        _buildAnimatedInput(
          controller: newPasswordController,
          labelText: "New Password",
          hintText: "Enter your new password",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        _buildAnimatedInput(
          controller: confirmPasswordController,
          labelText: "Confirm Password",
          hintText: "Confirm your new password",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
              shadowColor: Colors.blue.withOpacity(0.4),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              // Go back to verification code step
              setState(() {
                isCodeVerified = false;
                errorMessage = null;
              });
            },
            child: const Text(
              "Back",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedInput({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
