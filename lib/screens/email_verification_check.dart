import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'home.dart';

class EmailVerificationCheckScreen extends StatefulWidget {
  const EmailVerificationCheckScreen({super.key});

  @override
  State<EmailVerificationCheckScreen> createState() => _EmailVerificationCheckScreenState();
}

class _EmailVerificationCheckScreenState extends State<EmailVerificationCheckScreen> {
  final AuthService _auth = AuthService();
  bool isLoading = true;
  bool isVerified = false;
  String message = 'Checking verification status...';

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    setState(() => isLoading = true);

    final result = await _auth.checkEmailVerification();

    setState(() {
      isLoading = false;
      isVerified = result['verified'] ?? false;
      message = result['message'] ?? 'Unknown status';
    });

    if (isVerified) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() => isLoading = true);
    final result = await _auth.resendVerificationEmail();
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Email sent'),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
            if (!isLoading)
              Icon(
                isVerified ? Icons.verified : Icons.email_outlined,
                size: 80,
                color: isVerified ? Colors.green : Colors.orange,
              ),
            const SizedBox(height: 24),
            Text(
              isVerified ? '✅ Email Verified!' : 'Verify Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isVerified ? Colors.green : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 32),
            if (!isVerified && !isLoading) ...[
              ElevatedButton(
                onPressed: _resendVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Back to Login'),
              ),
            ],
            if (isVerified && !isLoading) ...[
              const SizedBox(height: 8),
              Text(
                'Redirecting to dashboard...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}