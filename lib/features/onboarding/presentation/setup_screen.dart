import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/fluenta_text_field.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _goalController = TextEditingController();
  final _languageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _goalController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _saveSetup() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('profiles').update({
        'goal': _goalController.text.trim(),
        'native_language': _languageController.text.trim(),
      }).eq('id', userId);

      if (mounted) {
        context.go('/placement');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.s32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text("Personalize your experience", style: AppTextStyles.display2),
                        const SizedBox(height: AppDimensions.s8),
                        Text(
                          "Answer a few questions so Lex can tailor your curriculum.",
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: AppDimensions.s48),
                        FluentaTextField(
                          label: "What's your main learning goal?",
                          controller: _goalController,
                          hintText: "e.g. Travel, Business, Academic...",
                          prefixIcon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: AppDimensions.s24),
                        FluentaTextField(
                          label: "What's your native language?",
                          controller: _languageController,
                          hintText: "e.g. Spanish, French, Arabic...",
                          prefixIcon: Icons.translate,
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        FluentaButton(
                          text: "Continue to Assessment",
                          onPressed: _saveSetup,
                          isLoading: _isLoading,
                          icon: Icons.arrow_forward,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
