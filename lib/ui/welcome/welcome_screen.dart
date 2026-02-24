import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../shared/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo section
              Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'HobbyHub',
                        style: AppTypography.headingLarge.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Illustration section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: Image.asset(
                        'assets/onbording.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Title & Subtitle section
              Column(
                children: [
                  Text(
                    'Discover your next\npassionate hobby',
                    textAlign: TextAlign.center,
                    style: AppTypography.headingLarge.copyWith(
                      fontSize: 32,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Connect with like-minded people and explore exciting communities near you.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Buttons section
              Column(
                children: [
                  PrimaryButton(
                    label: 'Create Account',
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Sign In',
                    onPressed: () => context.push(AppRoutes.login),
                  ),
                ],
              ),

              // Footer section
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
        children: const [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
