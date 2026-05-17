import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String? goal;
  final String? nativeLanguage;

  OnboardingState({this.goal, this.nativeLanguage});

  OnboardingState copyWith({String? goal, String? nativeLanguage}) {
    return OnboardingState(
      goal: goal ?? this.goal,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    );
  }
}

final onboardingProvider = StateProvider<OnboardingState>((ref) => OnboardingState());
