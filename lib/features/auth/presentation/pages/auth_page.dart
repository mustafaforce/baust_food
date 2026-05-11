import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/hero_band.dart';
import 'package:baust_food/features/auth/presentation/pages/login_page.dart';
import 'package:baust_food/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroBand(
                eyebrow: 'Baust Food',
                headline: _isLogin ? 'Welcome\nBack' : 'Join\nThe Table',
                subhead: _isLogin
                    ? 'Sign in to order from your campus vendors.'
                    : 'Create an account in seconds. We\'ll send a magic link.',
                trailing: const SpeechmarkOrb(size: 56, icon: Icons.restaurant_menu_rounded),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl2,
                  AppSpacing.xl3,
                  AppSpacing.xl2,
                  AppSpacing.xl3,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 14),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            final slideAnimation = Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slideAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: _isLogin
                              ? const LoginPage(key: ValueKey('login'))
                              : const SignupPage(key: ValueKey('signup')),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "Don't have an account?"
                                  : 'Already have an account?',
                              style: const TextStyle(
                                color: AppColors.body,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _isLogin = !_isLogin);
                              },
                              child: Text(
                                _isLogin ? 'Sign up' : 'Log in',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
