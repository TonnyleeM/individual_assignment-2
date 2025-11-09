import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.checkEmailVerified();

    if (isVerified && mounted) {
      // Email is verified, user will be automatically signed in via auth state listener
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! You can now sign in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _resendVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendEmailVerification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Verification email sent! Please check your inbox.'
                : authProvider.errorMessage ?? 'Failed to send verification email',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email icon
                const Icon(
                  Icons.email_outlined,
                  size: 100,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 30),
                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Message
                const Text(
                  'We\'ve sent a verification email to your inbox. Please check your email and click the verification link to activate your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Check verification button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'I\'ve Verified My Email',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                // Resend email button
                TextButton(
                  onPressed: _resendVerification,
                  child: const Text(
                    'Resend Verification Email',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Back to login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

