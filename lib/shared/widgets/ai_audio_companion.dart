import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class AiAudioCompanion extends StatefulWidget {
  final String textToSpeak;
  final String title;

  const AiAudioCompanion({
    super.key,
    required this.textToSpeak,
    this.title = "AI Narrator Guide",
  });

  @override
  State<AiAudioCompanion> createState() => _AiAudioCompanionState();
}

class _AiAudioCompanionState extends State<AiAudioCompanion> with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _isPaused = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _initTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isPaused = false;
          _waveController.repeat();
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _waveController.stop();
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _waveController.stop();
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _waveController.stop();
        });
      }
    });
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4); // easy-to-understand pace
    await _flutterTts.setPitch(1.0);
    
    // Extract plain text (remove markdown elements for cleaner TTS)
    final cleanText = widget.textToSpeak
        .replaceAll(RegExp(r'\*|_|#|`'), '')
        .trim();
        
    await _flutterTts.speak(cleanText);
  }

  Future<void> _pause() async {
    await _flutterTts.pause();
    if (mounted) {
      setState(() {
        _isPaused = true;
        _waveController.stop();
      });
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _waveController.stop();
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Audio Pulsating Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isPlaying ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.volume_up : Icons.headset_mic_outlined,
                  color: _isPlaying ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPlaying 
                          ? (_isPaused ? "Narration Paused" : "Listening to AI Audio Companion...") 
                          : "Listen to the AI read and explain this lesson out loud",
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Play/Pause button
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    if (_isPlaying && !_isPaused) {
                      _pause();
                    } else {
                      _speak();
                    }
                  },
                  icon: Icon(
                    _isPlaying && !_isPaused ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    _isPlaying && !_isPaused ? "Pause Audio" : "Listen Now",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                  ),
                ),
              ),
              if (_isPlaying) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.error),
                  tooltip: "Stop Narration",
                ),
              ],
            ],
          ),
          
          // Waveform indicator
          if (_isPlaying && !_isPaused) ...[
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(12, (index) {
                    final height = (index % 3 == 0)
                        ? (12 * _waveController.value + 4)
                        : (8 * _waveController.value + 4);
                    return Container(
                      width: 3,
                      height: height,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
