// onboarding_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/storage_providers.dart';

class OnboardingNotifier extends Notifier<bool> {
  OnboardingNotifier();
  @override
  bool build() {
    return ref
            .read(localStorageServiceProvider)
            .getBool(AppConstants.isFirstTimeKey) ??
        true;
  }

  Future<void> completeOnboarding() async {
    await ref
        .watch(localStorageServiceProvider)
        .setBool(AppConstants.isFirstTimeKey, false);
    state = false;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(() {
  return OnboardingNotifier();
});
