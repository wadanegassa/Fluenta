import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/skill_chip.dart';
import '../../../shared/models/profile.dart';
import '../../profile/data/profile_provider.dart';
import '../data/lessons_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (p) {
            final profile = p;
            if (profile == null) return const Center(child: Text("No profile found"));
            return _buildContent(context, profile);
          },
          loading: () => _buildLoading(context),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic profile) {
    return SingleChildScrollView(
      padding: AppDimensions.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.s24),
          _buildHeader(profile),
          const SizedBox(height: AppDimensions.s32),
          _buildStreakCard(profile),
          const SizedBox(height: AppDimensions.s32),
          _buildSectionHeader("Continue Learning"),
          const SizedBox(height: AppDimensions.s16),
          _buildCurrentLessonCard(context, profile),
          const SizedBox(height: AppDimensions.s32),
          _buildSectionHeader("Skill Progress"),
          const SizedBox(height: AppDimensions.s16),
          _buildSkillGrid(profile),
          const SizedBox(height: AppDimensions.s32),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic profile) {
    final hour = DateTime.now().hour;
    String greeting = "Good morning";
    if (hour >= 12 && hour < 17) greeting = "Good afternoon";
    if (hour >= 17) greeting = "Good evening";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$greeting, ${profile.fullName.split(' ')[0]}",
                style: AppTextStyles.h1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Ready for today's lesson?",
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primarySurface,
          backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl) : null,
          child: profile.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
        ),
      ],
    );
  }

  Widget _buildStreakCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${profile.streakDays} Day Streak",
                style: AppTextStyles.h2.copyWith(color: AppColors.accent),
              ),
              Text(
                "Keep it going, you're doing great!",
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.h2);
  }

  Widget _buildCurrentLessonCard(BuildContext context, dynamic profile) {
    return Consumer(
      builder: (context, ref, child) {
        final modulesAsync = ref.watch(modulesProvider(profile.level));
        
        return modulesAsync.when(
          data: (modules) {
            if (modules.isEmpty || modules[0].lessons.isEmpty) {
              return const SizedBox();
            }
            final nextLesson = modules[0].lessons[0];
            
            return GestureDetector(
              onTap: () => context.push('/lesson/${nextLesson.id}'),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.s24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            profile.level,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            modules[0].title.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(nextLesson.title, style: AppTextStyles.h1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SkillChip(skill: nextLesson.focusSkill ?? 'reading'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nextLesson.focusTopic,
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const LinearProgressIndicator(
                        value: 0.1,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceWarm,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => LoadingShimmer.card(),
          error: (_, __) => const SizedBox(),
        );
      },
    );
  }

  Widget _buildSkillGrid(dynamic profile) {
    final skills = [
      {'name': 'Reading', 'score': profile.readingAvg, 'color': AppColors.reading},
      {'name': 'Listening', 'score': profile.listeningAvg, 'color': AppColors.listening},
      {'name': 'Writing', 'score': profile.writingAvg, 'color': AppColors.writing},
      {'name': 'Speaking', 'score': profile.speakingAvg, 'color': AppColors.speaking},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: (skill['color'] as Color).withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: (skill['color'] as Color).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill['name'] as String, style: AppTextStyles.labelLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${skill['score']}%", style: AppTextStyles.h2),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: (skill['score'] as int) / 100,
                      strokeWidth: 4,
                      backgroundColor: (skill['color'] as Color).withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(skill['color'] as Color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: AppDimensions.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 24),
          LoadingShimmer(height: 60, borderRadius: 12),
          const SizedBox(height: 32),
          LoadingShimmer.card(),
          const SizedBox(height: 32),
          LoadingShimmer.card(),
        ],
      ),
    );
  }
}
