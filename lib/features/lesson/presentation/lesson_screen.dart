import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import 'lesson_notifier.dart';
import 'widgets/reading_section.dart';
import 'widgets/listening_section.dart';
import 'widgets/writing_section.dart';
import 'widgets/speaking_section.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextSection() {
    final currentSection = ref.read(lessonNotifierProvider(widget.lessonId)).currentSection;
    if (currentSection < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/lesson/\${widget.lessonId}/assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonNotifierProvider(widget.lessonId));

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.content == null) {
      return const Scaffold(body: Center(child: Text("Failed to load content")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Lesson Progress", style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            onPressed: () => _showAiTutor(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressStepper(state.currentSection),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (v) => ref.read(lessonNotifierProvider(widget.lessonId).notifier).setSection(v),
              physics: const NeverScrollableScrollPhysics(), // Force manual navigation
              children: [
                ReadingSection(content: state.content!, lessonId: widget.lessonId),
                ListeningSection(content: state.content!, lessonId: widget.lessonId),
                WritingSection(content: state.content!, lessonId: widget.lessonId),
                SpeakingSection(content: state.content!, lessonId: widget.lessonId),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(int currentSection) {
    final sections = ['Reading', 'Listening', 'Writing', 'Speaking'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(sections.length, (index) {
          final isCompleted = index < currentSection;
          final isActive = index == currentSection;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : (isCompleted ? AppColors.success : AppColors.border),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            "\${index + 1}",
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < sections.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.success : AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    final currentSection = ref.watch(lessonNotifierProvider(widget.lessonId)).currentSection;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: FluentaButton(
        text: currentSection == 3 ? "Complete Lesson" : "Next Section",
        onPressed: _nextSection,
        icon: Icons.arrow_forward,
      ),
    );
  }

  void _showAiTutor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(child: Center(child: Text("Lex AI Tutor Chat Coming Soon"))),
            ],
          ),
        ),
      ),
    );
  }
}
