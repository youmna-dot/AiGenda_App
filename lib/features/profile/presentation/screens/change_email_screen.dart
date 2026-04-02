import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/widgets/auth_helpers.dart';
import '../../logic/profile_cubit/profile_cubit.dart';
import '../../logic/profile_cubit/profile_state.dart';
import '../profile_widgets/shared_profile_widgets.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _newEmailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _isStep2 = false;
  bool _isSending = false;
  bool _isConfirming = false;
  bool _isSuccess = false;

  String? _errorMsg;
  String? _successMsg;

  // نحفظ الإيميل الجديد هنا عشان نعرضه في شاشة الـ success
  String _confirmedEmail = '';

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: إرسال الكود للإيميل الجديد ──
  Future<void> _sendCode() async {
    final email = _newEmailCtrl.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() => _errorMsg = 'Enter your new email address.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMsg = 'Enter a valid email address.');
      return;
    }

    final currentEmail =
        context.read<ProfileCubit>().currentProfile?.email ?? '';
    if (email == currentEmail.toLowerCase()) {
      setState(() =>
          _errorMsg = 'New email must be different from your current email.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorMsg = null;
      _successMsg = null;
    });

    await context.read<ProfileCubit>().changeEmail(newEmail: email);

    if (mounted) setState(() => _isSending = false);
  }

  // ── Step 2: تأكيد الكود ──
  Future<void> _confirmCode() async {
    final code = _codeCtrl.text.replaceAll(RegExp(r'\s+'), '').trim();

    if (code.isEmpty) {
      setState(() => _errorMsg = 'Enter the verification code.');
      return;
    }

    // نجيب الـ profile id
    var profile = context.read<ProfileCubit>().currentProfile;

    if (profile == null || profile.id.isEmpty) {
      // نحاول نحمل البروفايل
      final result =
          await context.read<ProfileCubit>().profileRepository.getProfile();
      result.fold(
        (failure) {
          setState(() => _errorMsg = 'Could not load profile. Please try again.');
          return;
        },
        (p) => profile = p,
      );
    }

    if (profile == null || profile!.id.isEmpty) {
      setState(() =>
          _errorMsg = 'Session expired. Please go back and try again.');
      return;
    }

    final newEmail = _newEmailCtrl.text.trim().toLowerCase();

    // ── Debug print (شيليها بعد ما تتأكدي إنه شغال) ──
    debugPrint('=== CONFIRM EMAIL CHANGE ===');
    debugPrint('  id       : "${profile!.id}"');
    debugPrint('  newEmail : "$newEmail"');
    debugPrint('  code     : "$code"');

    setState(() {
      _isConfirming = true;
      _errorMsg = null;
      _successMsg = null;
    });

    await context.read<ProfileCubit>().confirmChangeEmail(
          id: profile!.id,
          newEmail: newEmail,
          code: code,
        );

    if (mounted) setState(() => _isConfirming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // ── Step 1 نجح ──
          if (state is ChangeEmailSuccess) {
            setState(() {
              _isStep2 = true;
              _errorMsg = null;
              _successMsg =
                  'Code sent! Check ${_newEmailCtrl.text.trim()} inbox.';
            });
          }
          if (state is ChangeEmailFailure) {
            setState(() {
              _errorMsg = state.errMessage;
              _successMsg = null;
            });
          }

          // ── Step 2 نجح ──
          if (state is ConfirmChangeEmailSuccess) {
            _confirmedEmail = _newEmailCtrl.text.trim().toLowerCase();
            setState(() {
              _isSuccess = true;
              _errorMsg = null;
            });
          }
          if (state is ConfirmChangeEmailFailure) {
            setState(() {
              _errorMsg = state.errMessage;
              _successMsg = null;
            });
          }
        },
        builder: (context, state) {
          final isLoadingStep1 =
              _isSending || state is ChangeEmailLoading;
          final isLoadingStep2 =
              _isConfirming || state is ConfirmChangeEmailLoading;

          return SafeArea(
            child: _isSuccess
                ? _buildSuccessView(context)
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top Bar ──
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () => context.pop(),
                                child: backBtn()),
                            const SizedBox(width: 14),
                            Text('Change Email',
                                style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E0F5C))),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Icon ──
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8B6FD4),
                                  Color(0xFF5B3A9E)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C3FC8)
                                      .withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const Icon(Icons.email_outlined,
                                color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Current email ──
                        Center(
                          child: Column(
                            children: [
                              Text('Current email',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF8A84A3))),
                              const SizedBox(height: 4),
                              Text(
                                context
                                        .read<ProfileCubit>()
                                        .currentProfile
                                        ?.email ??
                                    '',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7C5CBF)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Card ──
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle(_isStep2
                                  ? 'Enter verification code'
                                  : 'New email address'),
                              const SizedBox(height: 6),
                              Text(
                                _isStep2
                                    ? 'We sent a code to ${_newEmailCtrl.text.trim()}'
                                    : 'Enter the new email address you want to use.',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF8A84A3)),
                              ),
                              const SizedBox(height: 16),

                              // ── Banners ──
                              if (_errorMsg != null) ...[
                                InfoBanner(
                                    message: _errorMsg!, isError: true),
                                const SizedBox(height: 14),
                              ],
                              if (_successMsg != null) ...[
                                InfoBanner(
                                    message: _successMsg!, isError: false),
                                const SizedBox(height: 14),
                              ],

                              // ── Step 1 ──
                              if (!_isStep2) ...[
                                _buildField(
                                  label: 'New Email',
                                  controller: _newEmailCtrl,
                                  hint: 'new@example.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !isLoadingStep1,
                                ),
                                const SizedBox(height: 20),
                                ProfileGradientButton(
                                  label: 'Send Verification Code',
                                  isLoading: isLoadingStep1,
                                  onTap: _sendCode,
                                ),
                              ],

                              // ── Step 2 ──
                              if (_isStep2) ...[
                                _buildField(
                                  label: 'Verification Code',
                                  controller: _codeCtrl,
                                  hint: 'Paste code from your new email',
                                  icon: Icons.lock_open_rounded,
                                  keyboardType: TextInputType.text,
                                  enabled: !isLoadingStep2,
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    '💡 Check the inbox of your NEW email: ${_newEmailCtrl.text.trim()}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF8A84A3)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ProfileGradientButton(
                                  label: 'Confirm Email Change',
                                  isLoading: isLoadingStep2,
                                  onTap: _confirmCode,
                                ),
                                const SizedBox(height: 12),

                                // Resend
                                Center(
                                  child: TextButton(
                                    onPressed: isLoadingStep1
                                        ? null
                                        : () async {
                                            setState(() {
                                              _errorMsg = null;
                                              _successMsg = null;
                                              _codeCtrl.clear();
                                            });
                                            setState(
                                                () => _isSending = true);
                                            await context
                                                .read<ProfileCubit>()
                                                .changeEmail(
                                                    newEmail: _newEmailCtrl
                                                        .text
                                                        .trim()
                                                        .toLowerCase());
                                            if (mounted) {
                                              setState(() =>
                                                  _isSending = false);
                                            }
                                          },
                                    child: Text(
                                      "Didn't receive it? Resend code",
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFF7C5CBF),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),

                                // Use different email
                                Center(
                                  child: TextButton(
                                    onPressed: () => setState(() {
                                      _isStep2 = false;
                                      _errorMsg = null;
                                      _successMsg = null;
                                      _codeCtrl.clear();
                                    }),
                                    child: Text(
                                      'Use a different email',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF8A84A3),
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor:
                                              const Color(0xFF8A84A3)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF0),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF4CAF50), width: 2.5),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF4CAF50), size: 52),
            ),
            const SizedBox(height: 28),
            Text('Email Changed! 🎉',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E0F5C))),
            const SizedBox(height: 10),
            Text(
              'Your email has been updated to:\n$_confirmedEmail',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF8A84A3),
                  height: 1.6),
            ),
            const SizedBox(height: 36),
            ProfileGradientButton(
              label: 'Back to Profile',
              isLoading: false,
              // ✅ لما يرجع للـ profile، الـ profile_screen هيعمل refreshProfile()
              // عشان الإيميل يتحدث في الشاشة
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A84A3))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF1E0F5C)),
          decoration: inputDecoration(hint: hint, icon: icon, enabled: enabled),
        ),
      ],
    );
  }
}