import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../shared/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              // Logo section
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HOBBYHUB',
                    style: AppTypography.headingLarge.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Illustration section - Flexible to fit screen
              Flexible(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/hobbyhub-demo/o/welcome_illustration.png?alt=media', // Имитация Firebase Storage
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Title & Subtitle section
              Column(
                children: [
                  Text(
                    'Find Your Tribe',
                    textAlign: TextAlign.center,
                    style: AppTypography.headingLarge.copyWith(
                      fontSize: 28,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover events, connect with communities, and explore new hobbies near you',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Buttons section
              Column(
                children: [
                  PrimaryButton(
                    label: 'Get Started',
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Sign In',
                    onPressed: () => context.push(AppRoutes.login),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Footer section
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
