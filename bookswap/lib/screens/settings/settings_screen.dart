import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (authProvider.user != null) ...[
                    Text(
                      'Name: ${authProvider.user!.displayName ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${authProvider.user!.email}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Settings Options
          Card(
            color: Colors.white.withOpacity(0.1),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Notification Reminders',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: true, // TODO: Implement notification settings
                  onChanged: (value) {
                    // TODO: Save notification preference
                  },
                  activeColor: AppColors.accent,
                ),
                const Divider(color: Colors.white24),
                SwitchListTile(
                  title: const Text(
                    'Email Updates',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: true, // TODO: Implement email settings
                  onChanged: (value) {
                    // TODO: Save email preference
                  },
                  activeColor: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // About Section
          Card(
            color: Colors.white.withOpacity(0.1),
            child: ListTile(
              title: const Text(
                'About',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About BookSwap'),
                    content: const Text('BookSwap v1.0.0\nA student textbook exchange app.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

