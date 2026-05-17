import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/fluenta_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isLoginInitial;
  const AuthScreen({super.key, this.isLoginInitial = true});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isLogin;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginInitial;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      
      if (_isLogin) {
        await authNotifier.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authNotifier.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }

      final state = ref.read(authNotifierProvider);
      if (state.hasError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        if (!mounted) return;
        if (_isLogin) {
          context.go('/home');
        } else {
          context.go('/setup');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top decorative block
                    Container(
                      height: constraints.maxHeight * 0.22,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'Fluenta',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Form Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                _isLogin ? 'Welcome Back' : 'Create Account',
                                style: AppTextStyles.h1.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLogin 
                                  ? 'Sign in to continue your journey.' 
                                  : 'Join us and start speaking with confidence.',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
                              ),
                              const SizedBox(height: 24),
                              if (!_isLogin) ...[
                                FluentaTextField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                  hintText: 'John Doe',
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) => v != null && v.length > 2 ? null : 'Too short',
                                ),
                                const SizedBox(height: 12),
                              ],
                              FluentaTextField(
                                label: 'Email',
                                controller: _emailController,
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
                              ),
                              const SizedBox(height: 12),
                              FluentaTextField(
                                label: 'Password',
                                controller: _passwordController,
                                isPassword: true,
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                validator: (v) => v != null && v.length >= 6 ? null : 'Too short',
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: FluentaButton(
                                  text: _isLogin ? 'Sign In' : 'Sign Up',
                                  onPressed: _handleSubmit,
                                  isLoading: authState.isLoading,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: _toggleMode,
                                  child: Text.rich(
                                    TextSpan(
                                      text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
                                      children: [
                                        TextSpan(
                                          text: _isLogin ? 'Sign up' : 'Sign in',
                                          style: AppTextStyles.labelLarge.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
