import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _offlineMode = false;
  bool _soundEffects = true;
  String _selectedLanguage = "English";

  final List<String> _languages = ["English", "Spanish", "French", "German", "Italian", "Arabic"];

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select App Language", style: AppTextStyles.h2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((lang) {
              return RadioListTile<String>(
                title: Text(lang, style: AppTextStyles.bodyMedium),
                value: lang,
                groupValue: _selectedLanguage,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Language changed to $_selectedLanguage successfully!"),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showTermsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Terms & Services", style: AppTextStyles.h1),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Last updated: May 17, 2026", style: AppTextStyles.caption),
                  const SizedBox(height: 24),
                  _buildTermsSection("1. Acceptance of Terms",
                      "Welcome to Voce. By accessing or using our application, mobile app, and related services, you agree to be bound by these Terms of Service. If you do not agree to all of these terms, please do not use our services."),
                  _buildTermsSection("2. User Accounts & Security",
                      "To unlock daily learning curriculum, diagnostic levels, and live chat features, you are required to register an account backed by secure Supabase user records. You are responsible for safeguarding your login credentials and are fully responsible for any activities conducted under your profile."),
                  _buildTermsSection("3. Permitted & Unpermitted Uses",
                      "You agree to use the application solely for personal, non-commercial education. You agree not to record, redistribute, or reverse engineer audio transcripts, speech-to-text algorithms, or generative Edge Functions powered by Gemini AI."),
                  _buildTermsSection("4. Intellectual Property Rights",
                      "All designs, layout systems, color systems, micro-animations, and database structures are owned exclusively by Voce. All rights not expressly granted are reserved by the developers."),
                  _buildTermsSection("5. Termination of Service",
                      "We reserve the right to suspend or block access to the dashboard or placement evaluations instantly for users violating our community guidelines or attempting unauthorized database modifications."),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("I Agree & Close", style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutPhoneDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("About Phone & System", style: AppTextStyles.h1),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSystemDetailRow("App Name", "Voce Language Portal"),
              _buildSystemDetailRow("App Version", "1.0.8 (Build 20260517)"),
              _buildSystemDetailRow("OS Platform", "Android OS 13 / Linux Kernel"),
              _buildSystemDetailRow("Hardware Architecture", "arm64-v8a"),
              _buildSystemDetailRow("Realtime Database Node", "Supabase PostgreSQL"),
              _buildSystemDetailRow("Speech STT Engine", "Android SpeechRecognizer"),
              _buildSystemDetailRow("AI Assistant Model", "Gemini 1.5 Pro Edge Node"),
              _buildSystemDetailRow("Device Status", "Connected (Low Latency)"),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Close Details", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermsSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSystemDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text("App Settings", style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PREFERENCES", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildToggleCard(
              Icons.notifications_none,
              "Push Notifications",
              "Receive reminders to practice daily",
              _pushNotifications,
              (val) => setState(() => _pushNotifications = val),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              Icons.wifi_off_outlined,
              "Offline Practice Mode",
              "Cache active curriculum tasks",
              _offlineMode,
              (val) => setState(() => _offlineMode = val),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              Icons.volume_up_outlined,
              "Sound Effects",
              "Audio feedback on quiz answers",
              _soundEffects,
              (val) => setState(() => _soundEffects = val),
            ),
            const SizedBox(height: 32),
            Text("LANGUAGE", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildActionCard(
              Icons.translate,
              "Selected App Language",
              _selectedLanguage,
              _showLanguageSelector,
            ),
            const SizedBox(height: 32),
            Text("LEGAL & SYSTEM", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildActionCard(
              Icons.gavel_outlined,
              "Terms & Services",
              "Terms of usage and legal bounds",
              _showTermsDialog,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              Icons.phone_android_outlined,
              "About Phone & System",
              "OS details and app architecture",
              _showAboutPhoneDialog,
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text("Voce Platform", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Version 1.0.8 • Made with Love", style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
