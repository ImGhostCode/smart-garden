import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/assets.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(),
            Image.asset(
              Assets.launcherIcon,
              width: 200,
              height: 150,
              fit: BoxFit.contain,
            ),
            Column(
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMd,
                  ),
                  child: Text(
                    'Manage gardens, zones, and watering schedules easily',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // backgroundColor: AppColors.neutral100,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMd,
          AppConstants.paddingSm,
          AppConstants.paddingMd,
          24,
        ),
        child: SizedBox(
          height: AppConstants.buttonMd,
          child: ElevatedButton(
            onPressed: () {
              ref.read(onboardingProvider.notifier).completeOnboarding();
            },
            child: const Text('START'),
          ),
        ),
      ),
    );
  }
}
