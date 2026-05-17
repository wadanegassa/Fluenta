import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/skill_chip.dart';
import 'placement_provider.dart';

class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key});

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementProvider);
    final notifier = ref.read(placementProvider.notifier);

    // If grading is finished, redirect to results with AI feedback!
    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(
          '/placement/result',
          extra: {
            'level': state.estimatedLevel,
            'feedback': state.feedback,
          },
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 1. Initial State: Show beautiful entrance introduction screen
    if (!state.hasStarted) {
      return _buildIntroductionScreen(notifier);
    }

    // 2. Loading State: Generating questions or grading
    if (state.isLoading || state.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  state.questions.isEmpty 
                      ? "Generating custom diagnostic exam..." 
                      : "AI Assessor is grading your response...",
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.questions.isEmpty
                      ? "Gemini is tailoring an exam covering Grammar, Vocabulary, Writing, and Speaking..."
                      : "Evaluating grammatical complexity, sentence structure, and vocabulary choice...",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = state.questions[state.currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (state.currentQuestionIndex + 1) / state.questions.length,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "QUESTION ${state.currentQuestionIndex + 1} OF ${state.questions.length}",
              style: AppTextStyles.caption.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkillChip(skill: currentQuestion.skill),
                Text(
                  "Level: Diagnostic",
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 💡 Beautiful Concept Focus card ("Before the question, the app understands the idea")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Linguistic Focus",
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentQuestion.concept,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Question Text
            Text(
              currentQuestion.text,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 32),

            // Input section depending on type (mcq, writing, speaking)
            if (currentQuestion.type == 'mcq')
              _buildMcqOptions(currentQuestion, notifier)
            else if (currentQuestion.type == 'writing')
              _buildWritingInput(currentQuestion, notifier)
            else
              _buildSpeakingInput(currentQuestion, notifier),
          ],
        ),
      ),
    );
  }

  // Beautiful Entrance Introduction screen
  Widget _buildIntroductionScreen(PlacementNotifier notifier) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology, size: 72, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                "Diagnostic Entrance Exam",
                style: AppTextStyles.display1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Think carefully and answer these questions.",
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "This dynamic placement test evaluates your skills across Multiple Choice grammar exercises, open-ended descriptive Writing, and real-life polite Speaking scenarios. At the end, an AI Assessor reviews all responses collectively to determine your optimal learning roadmap.",
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _FeatureRow(icon: Icons.checklist, text: "5 Grammar & Vocabulary MCQs"),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.edit_note, text: "3 Descriptive Paragraph Writing prompts"),
                    SizedBox(height: 12),
                    _FeatureRow(icon: Icons.chat_bubble_outline, text: "2 Conversational Speaking prompts"),
                  ],
                ),
              ),
              const Spacer(),
              FluentaButton(
                text: "Begin Assessment",
                onPressed: () {
                  notifier.startTest();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MCQ selection grid
  Widget _buildMcqOptions(PlacementQuestion currentQuestion, PlacementNotifier notifier) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentQuestion.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final option = currentQuestion.options[index];
        return _OptionCard(
          text: option,
          onTap: () {
            notifier.submitAnswer(currentQuestion.id, option);
          },
        );
      },
    );
  }

  // Writing open-ended card
  Widget _buildWritingInput(PlacementQuestion currentQuestion, PlacementNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _inputController,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: "E.g., Yesterday, I went to a local coffee shop to read my favorite novel. Afterward, I met up with...",
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FluentaButton(
          text: "Submit Answer",
          onPressed: () {
            final text = _inputController.text.trim();
            if (text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please write down your response before submitting!")),
              );
              return;
            }
            _inputController.clear();
            notifier.submitAnswer(currentQuestion.id, text);
          },
        ),
      ],
    );
  }

  // Speaking scenario response card
  Widget _buildSpeakingInput(PlacementQuestion currentQuestion, PlacementNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.speaking.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: AppColors.speaking.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.record_voice_over, color: AppColors.speaking),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Type what you would verbally say in this social situation:",
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.speaking, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: _inputController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Write down your spoken words here...",
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FluentaButton(
          text: "Submit Answer",
          onPressed: () {
            final text = _inputController.text.trim();
            if (text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please type your spoken words before submitting!")),
              );
              return;
            }
            _inputController.clear();
            notifier.submitAnswer(currentQuestion.id, text);
          },
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionCard({required this.text, required this.onTap});

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isSelected = true);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isSelected = false);
          }
          widget.onTap();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (_isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
