// onboarding/presentation/widgets/onboarding_slide.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/onboarding_model.dart';
import 'onboarding_page_indicator.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingModel dataModel;
  final String buttonText;
  final int currentPage;
  final int pageCount;
  final VoidCallback onButtonTap;

  const OnboardingSlide({
    super.key,
    required this.dataModel,
    required this.buttonText,
    required this.currentPage,
    required this.pageCount,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        // ── Image — تاخد المساحة المتبقية فوق ──
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF0EEF8),
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Image.asset(
              dataModel.image,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // ── Bottom White Card ──
        Container(
          width: double.infinity,
          // ارتفاع ثابت عشان يكون زي الصورة بالظبط
          height: size.height * 0.37,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A6C3FC8),
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Handle ──
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CBF).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                Text(
                  dataModel.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E0F5C),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Description ──
                Text(
                  dataModel.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: const Color(0xFF8A84A3),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                // ── Button ──
                _OnboardingButton(
                  text: buttonText,
                  onTap: onButtonTap,
                ),
                const SizedBox(height: 20),

                // ── Dots ──
                OnboardingIndicator(
                  currentIndex: currentPage,
                  length: pageCount,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Button — زي الصورة بالظبط ──
class _OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _OnboardingButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3FC8).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 10),
            // ── السهم بدون box ──
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}