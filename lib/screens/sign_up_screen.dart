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
                  const SizedBox(height: 20),

                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _buildInputDecoration("Full name"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your full name" : null,
                  ),
                  const SizedBox(height: 15),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: _buildInputDecoration("Email"),
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
                  TextFormField(
                    controller: _mobileNumberController,
                    decoration: _buildInputDecoration("Mobile Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? "Enter your mobile number" : null,
                  ),
                  const SizedBox(height: 15),

                  // Date of Birth Field with date picker
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration:
                        _buildInputDecoration("Date of Birth (DD/MM/YYYY)")
                            .copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.grey),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your date of birth" : null,
                  ),
                  const SizedBox(height: 15),

                  // Password Field with visibility toggle
                  TextFormField(
                    controller: _passwordController,
                    decoration: _buildInputDecoration("Password").copyWith(
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
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter a password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Error message
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
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
    }
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
