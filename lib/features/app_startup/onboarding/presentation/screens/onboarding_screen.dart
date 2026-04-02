// onboarding/presentation/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../data/models/onboarding_data.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _pages = OnboardingData.list;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage == _pages.length - 1) {
      context.go(RouteNames.login);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => OnboardingSlide(
              dataModel: _pages[i],
              buttonText: i == _pages.length - 1
                  ? AppStrings.getStarted
                  : AppStrings.next,
              currentPage: _currentPage,
              pageCount: _pages.length,
              onButtonTap: _goNext,
            ),
          ),
          // ── Skip button ──
          Positioned(
            top: 52,
            right: 20,
            child: TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(
                AppStrings.skip,
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}