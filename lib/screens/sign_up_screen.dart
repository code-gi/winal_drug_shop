import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:winal_front_end/utils/auth_provider.dart';
import 'package:winal_front_end/screens/login_screen.dart';
import 'package:winal_front_end/services/email_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for capturing user input
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for password visibility
  bool _obscurePassword = true;

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
                  const SizedBox(height: 20),

                  // First Name Field
                  _buildFormField(
                    controller: _firstNameController,
                    hintText: "First Name",
                    fieldKey: "first_name",
                    authProvider: authProvider,
                    validator: (value) =>
                        value!.trim().isEmpty ? "Enter your first name" : null,
                  ),
                  const SizedBox(height: 15),

                  // Last Name Field
                  _buildFormField(
                    controller: _lastNameController,
                    hintText: "Last Name",
                    fieldKey: "last_name",
                    authProvider: authProvider,
                    validator: (value) =>
                        value!.trim().isEmpty ? "Enter your last name" : null,
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    validator: (value) {
                      final phoneNumber = value?.trim() ?? '';
                      if (phoneNumber.isEmpty) {
                        return "Enter your mobile number";
                      }
                      if (!RegExp(r'^(?:\+256|0)7\d{8}$').hasMatch(phoneNumber)) {
                        return "Use a valid Ugandan mobile number like 0701234567 or +256701234567";
                      }
                      return null;
                    },
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
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.grey),
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
                      final errors = _getPasswordErrors(value ?? '');
                      return errors.isEmpty ? null : errors.join('\n');
                    },
                  ),
                  const SizedBox(height: 30),

                  // Error message and field errors summary
                  if (authProvider.errorMessage != null ||
                      authProvider.fieldErrors != null)
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
                              final fieldName =
                                  entry.value['field_name'] ?? entry.key;
                              final errors =
                                  entry.value['errors'] as List<dynamic>? ?? [];
                              final message = errors.isNotEmpty
                                  ? errors
                                      .map((error) => error.toString())
                                      .join('; ')
                                  : 'Invalid';
                              return Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("- ",
                                        style: TextStyle(
                                            color: Colors.red.shade600)),
                                    Expanded(
                                      child: Text(
                                        "$fieldName: $message",
                                        style: TextStyle(
                                            color: Colors.red.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
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
                          : () => _handleSignUp(authProvider),
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
  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName'.trim();

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _normalizePhoneNumber(_mobileNumberController.text),
        dateOfBirth: _formatDateForApi(_dateOfBirthController.text),
      );

      if (!mounted) return;

      if (success) {
        // Send welcome email
        try {
          final success = await _emailService.sendTestEmail(
            to: _emailController.text.trim(),
            subject: 'Welcome to Winal Drug Shop!',
            content: 'Thank you for signing up, $fullName!',
          );

          if (success) {
            debugPrint(
                'Welcome email sent successfully to ${_emailController.text.trim()}');
          } else {
            debugPrint('Failed to send welcome email');
          }
        } catch (e) {
          debugPrint('Error sending welcome email: $e');
        }

        if (!mounted) return;

        _showSignUpSuccess(context);
        // Navigate to login screen after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    }
  }

  List<String> _getPasswordErrors(String password) {
    if (password.isEmpty) {
      return ["Enter a password"];
    }

    final errors = <String>[];
    if (password.length < 8) {
      errors.add(
        "Add at least ${8 - password.length} more character${password.length == 7 ? '' : 's'}",
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add("Add a lowercase letter");
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add("Add an uppercase letter");
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add("Add a number");
    }
    return errors;
  }

  String _normalizePhoneNumber(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }
    return trimmed.replaceAll(RegExp(r'\D'), '');
  }

  String _formatDateForApi(String displayDate) {
    final trimmed = displayDate.trim();
    final parts = trimmed.split('/');

    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }
    }

    return trimmed;
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
    }
  }

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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
