import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService auth = AuthService();
  bool isLoading = false;
  bool isSent = false;

  Future<void> sendReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Enter your email address", Colors.red);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar("Please enter a valid email", Colors.red);
      return;
    }

    setState(() => isLoading = true);
    final bool success = await auth.resetPassword(email);
    setState(() => isLoading = false);

    if (success && mounted) {
      setState(() => isSent = true);
      _showSnackBar("✅ Password reset email sent! Check your inbox.", Colors.green);
    } else {
      _showSnackBar("❌ Failed to send reset email. Please try again.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/ali.jpeg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.lock_reset, size: 50, color: Colors.green.shade700);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            if (!isSent) ...[
              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "you@example.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                onPressed: sendReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Send Reset Link",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            if (isSent) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.email, size: 60, color: Colors.green.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      "Check Your Email",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "A password reset link has been sent to\n${emailController.text}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            ],

            if (!isSent) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}