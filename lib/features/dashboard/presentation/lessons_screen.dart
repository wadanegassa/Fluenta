import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/level_badge.dart';
import '../../../shared/widgets/skill_chip.dart';
import '../../../shared/models/profile.dart';
import '../../profile/data/profile_provider.dart';
import '../data/lessons_provider.dart';
import '../data/progress_provider.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Curriculum", style: AppTextStyles.h1),
        actions: [
          profileAsync.when(
            data: (p) => p != null 
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: LevelBadge(level: p.level),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (p) {
          final profile = p;
          if (profile == null) return const SizedBox();
          final modulesAsync = ref.watch(modulesProvider(profile.level));
          return modulesAsync.when(
            data: (modules) {
              final progressAsync = ref.watch(userProgressProvider);
              
              return progressAsync.when(
                data: (progressList) => ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.s20),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    
                    // A module is unlocked if it's the first one OR if any of its lessons are unlocked
                    bool isUnlocked = index == 0;
                    if (!isUnlocked) {
                      isUnlocked = module.lessons.any((lesson) => 
                        progressList.any((p) => p.lessonId == lesson.id && p.isUnlocked)
                      );
                    }

                    return _ModuleSection(module: module, isUnlocked: isUnlocked);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _ModuleSection extends ConsumerWidget {
  final dynamic module;
  final bool isUnlocked;

  const _ModuleSection({required this.module, required this.isUnlocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      module.title.toUpperCase(),
                      style: AppTextStyles.labelMedium.copyWith(
                        letterSpacing: 1.2,
                        color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (isUnlocked)
          ...module.lessons.map((lesson) => _LessonCard(lesson: lesson)).toList()
        else
          Container(
            padding: const EdgeInsets.all(AppDimensions.s20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: const Center(
              child: Text(
                "Complete previous modules to unlock",
                style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textTertiary),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final dynamic lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    
    return progressAsync.when(
      data: (progressList) {
        final progress = progressList.firstWhere(
          (p) => p.lessonId == lesson.id,
          orElse: () => LessonProgress(lessonId: lesson.id, isUnlocked: lesson.orderIndex == 0, isMastered: false),
        );

        final isUnlocked = progress.isUnlocked || lesson.orderIndex == 0; 
        final isMastered = progress.isMastered;

        return GestureDetector(
          onTap: isUnlocked ? () => context.push('/lesson/${lesson.id}') : () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Complete previous lessons to unlock this one!")),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppDimensions.s16),
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.surface : AppColors.surfaceWarm.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: isUnlocked ? AppColors.border : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.primarySurface : AppColors.border.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isMastered
                        ? const Icon(Icons.check, color: AppColors.success)
                        : isUnlocked
                            ? Text("${lesson.orderIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))
                            : const Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: AppTextStyles.h3.copyWith(
                          color: isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SkillChip(skill: lesson.focusSkill ?? 'general'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lesson.focusTopic,
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUnlocked && !isMastered)
                  const Icon(Icons.chevron_right, color: AppColors.borderStrong),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(),
    );
  }
}
