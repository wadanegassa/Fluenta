import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class SpeakingSection extends ConsumerStatefulWidget {
  final LessonContent content;
  final String lessonId;

  const SpeakingSection({
    super.key,
    required this.content,
    required this.lessonId,
  });

  @override
  ConsumerState<SpeakingSection> createState() => _SpeakingSectionState();
}

class _SpeakingSectionState extends ConsumerState<SpeakingSection> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;
  
  // Speech to Text members
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _wordsSpoken = "";
  final TextEditingController _fallbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      final available = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      debugPrint('STT initialization error: $e');
    }
  }

  Future<void> _startListening() async {
    if (_speechAvailable) {
      setState(() {
        _isRecording = true;
        _wordsSpoken = "";
      });
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _wordsSpoken = result.recognizedWords;
              if (result.finalResult) {
                ref.read(lessonNotifierProvider(widget.lessonId).notifier).saveAnswer(
                  'speaking_submission',
                  _wordsSpoken,
                );
              }
            });
          }
        },
      );
    } else {
      // Re-try initializing or notify
      await _initSpeech();
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Voice engine not available. Please use keyboard input below!")),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isRecording = false;
    });
    if (_wordsSpoken.isNotEmpty) {
      ref.read(lessonNotifierProvider(widget.lessonId).notifier).saveAnswer(
        'speaking_submission',
        _wordsSpoken,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonNotifierProvider(widget.lessonId));
    final hasSpeech = state.answers['speaking_submission'] != null;
    final currentAnswer = state.answers['speaking_submission']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkillChip(skill: 'speaking'),
          const SizedBox(height: 16),
          Text("Speaking Exercise", style: AppTextStyles.h1),
          const SizedBox(height: 24),
          _buildPromptCard(),
          const SizedBox(height: 40),
          
          if (_speechAvailable) ...[
            Center(child: _buildRecordButton()),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _isRecording 
                    ? "Listening... speak now" 
                    : (hasSpeech ? "Speech recorded! Tap mic to record again" : "Tap to speak your response"),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _isRecording ? AppColors.error : AppColors.textSecondary,
                  fontWeight: hasSpeech ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // Beautiful Transcription preview container
            if (_wordsSpoken.isNotEmpty || currentAnswer.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Live Transcription",
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording ? _wordsSpoken : currentAnswer,
                      style: AppTextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // Keyboard fallback if STT is unavailable (emulators, hardware limits)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.keyboard, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text("Keyboard Fallback Mode", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Speech engine is not initialized. Please type what you would say verbally to complete the lesson.",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _fallbackController,
              maxLines: 4,
              onChanged: (v) {
                ref.read(lessonNotifierProvider(widget.lessonId).notifier).saveAnswer(
                  'speaking_submission',
                  v,
                );
              },
              decoration: InputDecoration(
                hintText: "Type your oral response...",
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: AppColors.speakingLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: const Border(
          left: BorderSide(color: AppColors.speaking, width: 4),
        ),
      ),
      child: Text(
        widget.content.speakingPrompt,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () {
        if (_isRecording) {
          _stopListening();
        } else {
          _startListening();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isRecording)
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.2),
                ),
              ),
            ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColors.error : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.error : AppColors.primary).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
