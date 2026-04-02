// onboarding/data/models/onboarding_data.dart
// عدّلنا الـ titles لـ English زي الصور القديمة

import 'package:ajenda_app/core/constants/app_assets.dart';
import 'onboarding_model.dart';

class OnboardingData {
  static List<OnboardingModel> get list => [
    OnboardingModel(
      image: AppAssets.onboarding1,
      title: 'Plan Smarter with AI',
      description:
          'Let AI genda organize your tasks and schedule efficiently.',
    ),
    OnboardingModel(
      image: AppAssets.onboarding2,
      title: 'Boost Your Productivity',
      description:
          'AI genda helps you stay organized and focused on what matters.',
    ),
    OnboardingModel(
      image: AppAssets.onboarding3,
      title: 'Achieve Your Goals with AI',
      description:
          'Aigenda guides you towards better time management and goal achievement.',
    ),
  ];
}