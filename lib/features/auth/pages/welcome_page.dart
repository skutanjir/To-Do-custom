import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/primary_button.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/secondary_button.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/logo.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/login_page.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/register_page.dart';
import 'package:pdbl_testing_custom_mobile/features/shell/pages/main_navigation.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(authService: authService),
        ),
      );
      return;
    }
    if (mounted) setState(() => _checkingSession = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.15 : 32.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Logo Container with soft shadow
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const NexuzeLogo(),
                        ),

                        const SizedBox(height: 56),

                        // Tagline
                        const Text(
                          'Master your time,\nachieve more.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.0,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Subtitle
                        const Text(
                          'A minimalist time management solution.\nHelping you organize your activities elegantly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const Spacer(flex: 4),

                        // Buttons Column for more elegance instead of cramped row
                        PrimaryButton(
                          label: 'Log In',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        SecondaryButton(
                          label: 'Create Account',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Guest button
                        TextButton(
                          onPressed: () async {
                            final authService = AuthService();
                            await authService.enterGuestMode();
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MainNavigation(authService: authService),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
