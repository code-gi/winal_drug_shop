import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/utils/auth_provider.dart';
import 'package:winal_front_end/screens/login_screen.dart';
import 'package:winal_front_end/services/email_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for capturing user input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for password visibility
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Create an instance of EmailService
  final EmailService _emailService = EmailService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "New Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),                  // Full Name Field
                  _buildFormField(
                    controller: _fullNameController,
                    hintText: "Full name",
                    fieldKey: "first_name", // Backend uses first_name for validation
                    authProvider: authProvider,
                    validator: (value) =>
                        value!.isEmpty ? "Enter your full name" : null,
                  ),
                  const SizedBox(height: 15),

                  // Email Field
                  _buildFormField(
                    controller: _emailController,
                    hintText: "Email",
                    fieldKey: "email",
                    authProvider: authProvider,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter an email";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Mobile Number Field
                  _buildFormField(
                    controller: _mobileNumberController,
                    hintText: "Mobile Number",
                    fieldKey: "phone_number",
                    authProvider: authProvider,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? "Enter your mobile number" : null,
                  ),
                  const SizedBox(height: 15),

                  // Date of Birth Field with date picker
                  _buildFormField(
                    controller: _dateOfBirthController,
                    hintText: "Date of Birth (DD/MM/YYYY)",
                    fieldKey: "date_of_birth",
                    authProvider: authProvider,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                      onPressed: () => _selectDate(context),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your date of birth" : null,
                  ),
                  const SizedBox(height: 15),

                  // Password Field with visibility toggle
                  _buildFormField(
                    controller: _passwordController,
                    hintText: "Password",
                    fieldKey: "password",
                    authProvider: authProvider,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter a password";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),                  // Error message and field errors summary
                  if (authProvider.errorMessage != null || authProvider.fieldErrors != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (authProvider.errorMessage != null)
                            Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (authProvider.fieldErrors != null) ...[
                            if (authProvider.errorMessage != null)
                              const SizedBox(height: 8),
                            Text(
                              "Please fix the following issues:",
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...authProvider.fieldErrors!.entries.map((entry) {
                              final fieldName = entry.value['field_name'] ?? entry.key;
                              final errors = entry.value['errors'] as List<dynamic>? ?? [];
                              return Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("• ", style: TextStyle(color: Colors.red.shade600)),
                                    Expanded(
                                      child: Text(
                                        "$fieldName: ${errors.isNotEmpty ? errors.first : 'Invalid'}",
                                        style: TextStyle(color: Colors.red.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleSignUp(context, authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle sign up
  Future<void> _handleSignUp(
      BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      // Extract first and last name from the full name
      List<String> nameParts = _fullNameController.text.split(' ');
      String firstName = nameParts[0];
      String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final success = await authProvider.register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _mobileNumberController.text,
        dateOfBirth: _dateOfBirthController.text,
      );

      if (success) {
        // Send welcome email
        try {
          final success = await _emailService.sendTestEmail(
            to: _emailController.text,
            subject: 'Welcome to Winal Drug Shop!',
            content: 'Thank you for signing up, ${_fullNameController.text}!',
          );

          if (success) {
            print(
                'Welcome email sent successfully to ${_emailController.text}');
          } else {
            print('Failed to send welcome email');
          }
        } catch (e) {
          print('Error sending welcome email: $e');
        }

        _showSignUpSuccess(context);
        // Navigate to login screen after short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    }
  }

  // Extract initials from the full name
  String _getInitials(String fullName) {
    List<String> names = fullName.split(" ");
    String initials = "";
    for (var name in names) {
      if (name.isNotEmpty) {
        initials += name[0].toUpperCase();
      }
    }
    return initials;
  }

  // Input Decoration
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Show success message
  void _showSignUpSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sign Up Successful! Redirecting to Login..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Select date from calendar
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }  }

  // Helper method to build form fields with backend error support
  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required String fieldKey,
    required AuthProvider authProvider,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    final hasBackendError = authProvider.hasFieldError(fieldKey);
    final backendError = authProvider.getFieldError(fieldKey);
    final fieldRequirement = authProvider.getFieldRequirement(fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: _buildInputDecoration(hintText).copyWith(
            suffixIcon: suffixIcon,
            errorBorder: hasBackendError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  )
                : null,
            focusedErrorBorder: hasBackendError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
        ),
        if (hasBackendError && backendError != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backendError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                if (fieldRequirement != null)
                  Text(
                    fieldRequirement,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
