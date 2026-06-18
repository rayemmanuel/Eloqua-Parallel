import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: Ensure your theme_manager_ext.dart is imported here or in a global scope
// import '../../core/theme/theme_manager_ext.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager_ext.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Premium Input Field
// ═════════════════════════════════════════════════════════════════════════════

class _PremiumInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool obscureText;
  final int? maxLines;

  const _PremiumInputField({
    required this.label,
    required this.placeholder,
    required this.controller,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  State<_PremiumInputField> createState() => _PremiumInputFieldState();
}

class _PremiumInputFieldState extends State<_PremiumInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_updateFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateFocus() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: tt.labelMedium?.copyWith(
            color: _isFocused ? cs.primary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Input Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? cs.primary : cs.outlineVariant,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: tt.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused ? cs.primary : cs.onSurfaceVariant,
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ForgotPasswordScreen
// ═════════════════════════════════════════════════════════════════════════════

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  // Restored your exact backend logic utilizing Provider and result objects
  Future<void> _send() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    HapticService.instance.medium();
    setState(() {
      _loading = true;
      _error = null;
    });

    final result =
        await context.read<AuthService>().sendPasswordReset(_email.text.trim());

    if (mounted) {
      setState(() {
        _loading = false;
        if (result.success) {
          _sent = true;
          _error = null;
        } else {
          _error = result.errorMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: isParadise
            ? BoxDecoration(
                color: cs.surface,
                image: const DecorationImage(
                  image: AssetImage('assets/images/mesh_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.08,
                ),
              )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.instance.light();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: cs.outlineVariant, width: 0.5),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: cs.onSurface,
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'RECOVERY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36), // Balance the back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Lock icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: cs.primary.withOpacity(0.2), width: 0.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock_reset_rounded,
                            color: cs.primary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Restored your Strings, utilizing premium typography
                      Text(
                        AppStrings.forgotTitle,
                        style: isParadise
                            ? GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                height: 1.1,
                              )
                            : tt.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.forgotSubtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Main card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_sent)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cs.tertiaryContainer.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: cs.tertiary.withOpacity(0.3),
                                      width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cs.tertiary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: cs.tertiary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Link Sent!',
                                            style: tt.titleSmall?.copyWith(
                                              color: cs.tertiary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            AppStrings.forgotSuccess,
                                            style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              _PremiumInputField(
                                label: AppStrings.forgotEmail,
                                placeholder: 'hello@creative.com',
                                controller: _email,
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _send(),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _error!,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 24),
                            if (_sent)
                              GestureDetector(
                                onTap: () {
                                  HapticService.instance.light();
                                  Navigator.pop(context);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.forgotBack,
                                      style: tt.labelLarge?.copyWith(
                                        color: cs.onPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: _loading ? null : _send,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: _loading
                                        ? cs.primary.withOpacity(0.6)
                                        : cs.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _loading
                                        ? const []
                                        : [
                                            BoxShadow(
                                              color:
                                                  cs.primary.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: cs.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            AppStrings.forgotBtn,
                                            style: isParadise
                                                ? GoogleFonts.oswald(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.2,
                                                    color: cs.onPrimary,
                                                  )
                                                : tt.labelLarge?.copyWith(
                                                    color: cs.onPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                          ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
