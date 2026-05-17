import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/level_badge.dart';
import '../../../shared/widgets/skill_progress_bar.dart';
import '../../../shared/models/profile.dart';
import '../../auth/data/auth_provider.dart';
import '../data/profile_provider.dart';
import '../../dashboard/data/lessons_provider.dart';
import '../../dashboard/data/progress_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Profile", style: AppTextStyles.h1),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profileAsync.when(
        data: (p) {
          final profile = p as Profile?;
          if (profile == null) return const Center(child: Text("No profile found"));
          return _buildContent(context, ref, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic profile) {
    return SingleChildScrollView(
      padding: AppDimensions.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildHeader(profile),
          const SizedBox(height: 32),
          _buildLevelProgressCard(context, ref, profile),
          const SizedBox(height: 32),
          _buildStatsRow(profile),
          const SizedBox(height: 32),
          _buildSkillProgress(profile),
          const SizedBox(height: 32),
          _buildActionList(context, ref),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primarySurface,
          child: const Icon(Icons.person, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(profile.fullName, style: AppTextStyles.display2),
        const SizedBox(height: 8),
        LevelBadge(level: profile.level),
      ],
    );
  }

  Widget _buildStatsRow(dynamic profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(profile.streakDays.toString(), "Day Streak", Icons.local_fire_department, AppColors.accent),
          _buildStatItem(profile.totalLessonsMastered.toString(), "Lessons Done", Icons.check_circle, AppColors.success),
          _buildStatItem("82%", "Avg Score", Icons.stars, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.h2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildSkillProgress(dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Detailed Progress", style: AppTextStyles.h2),
        const SizedBox(height: 24),
        SkillProgressBar(skillName: "Reading", progress: profile.readingAvg / 100, color: AppColors.reading),
        const SizedBox(height: 20),
        SkillProgressBar(skillName: "Listening", progress: profile.listeningAvg / 100, color: AppColors.listening),
        const SizedBox(height: 20),
        SkillProgressBar(skillName: "Writing", progress: profile.writingAvg / 100, color: AppColors.writing),
        const SizedBox(height: 20),
        SkillProgressBar(skillName: "Speaking", progress: profile.speakingAvg / 100, color: AppColors.speaking),
      ],
    );
  }

  Widget _buildActionList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildActionTile(Icons.edit_outlined, "Edit Profile", () {}),
        _buildActionTile(Icons.notifications_none, "Notification Settings", () {}),
        _buildActionTile(Icons.language, "Language Preferences", () {}),
        _buildActionTile(Icons.logout, "Sign Out", () async {
          await ref.read(authNotifierProvider.notifier).signOut();
          if (context.mounted) context.go('/login');
        }, color: AppColors.error),
      ],
    );
  }

  Widget _buildLevelProgressCard(BuildContext context, WidgetRef ref, dynamic profile) {
    final modulesAsync = ref.watch(modulesProvider(profile.level));
    final progressAsync = ref.watch(userProgressProvider);

    return modulesAsync.when(
      data: (modules) {
        return progressAsync.when(
          data: (progressList) {
            int totalLessons = 0;
            int masteredInCurrentLevel = 0;

            for (var m in modules) {
              for (var l in m.lessons) {
                totalLessons++;
                if (progressList.any((p) => p.lessonId == l.id && p.isMastered)) {
                  masteredInCurrentLevel++;
                }
              }
            }

            final progress = totalLessons > 0 ? masteredInCurrentLevel / totalLessons : 0.0;
            final remaining = totalLessons - masteredInCurrentLevel;
            
            String nextLevel = 'Master';
            const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
            final idx = levels.indexOf(profile.level);
            if (idx != -1 && idx < levels.length - 1) {
              nextLevel = levels[idx + 1];
            }

            return Container(
              padding: const EdgeInsets.all(AppDimensions.s24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Road to $nextLevel",
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    remaining > 0 
                        ? "Master $remaining more lessons to unlock level $nextLevel"
                        : "You have mastered all lessons in this level!",
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
    );
  }
}
