import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Logo section
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
                ).animate().fade(duration: 600.ms).slideY(begin: -0.2),

                const SizedBox(height: 48),

                // Illustration
                Container(
                      height: 340,
                      width: double.infinity,
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
                            'https://images.unsplash.com/photo-1529156069898-49953e39b300?q=80&w=2000&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: 800.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 64),

                // Title
                Text(
                      'Find Your Tribe',
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: 32,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                      'Discover events, connect with communities, and explore new hobbies near you',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 48),

                // Buttons
                PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => context.push(AppRoutes.register),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 600.ms)
                    .slideX(begin: -0.1),

                const SizedBox(height: 16),

                SecondaryButton(
                      label: 'Sign In',
                      onPressed: () => context.push(AppRoutes.login),
                      padding: EdgeInsets.zero,
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 700.ms)
                    .slideX(begin: 0.1),

                const SizedBox(height: 32),

                // Footer
                _buildFooter().animate().fade(duration: 800.ms, delay: 900.ms),
              ],
            ),
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
