import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/fluenta_text_field.dart';
import '../data/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
      
      final state = ref.read(authNotifierProvider);
      if (state.hasError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      } else {
        if (!mounted) return;
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Text(
                  'Fluenta',
                  style: AppTextStyles.display1.copyWith(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppDimensions.s32),
                    FluentaTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      hintText: 'John Doe',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v != null && v.length > 2 ? null : 'Too short',
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    FluentaTextField(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    FluentaTextField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      validator: (v) => v != null && v.length >= 6 ? null : 'Too short',
                    ),
                    const SizedBox(height: AppDimensions.s32),
                    FluentaButton(
                      text: 'Sign Up',
                      onPressed: _signUp,
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: AppDimensions.s24),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: AppTextStyles.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                ),
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
          ],
        ),
      ),
    );
  }
}
