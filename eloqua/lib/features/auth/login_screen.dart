import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: Ensure your theme_manager_ext.dart is imported here or in a global scope
// import '../../core/theme/theme_manager_ext.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/haptic_service.dart';
import '../../main.dart'; // For RootShell
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../../core/theme/theme_manager_ext.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Premium Input Widget (Adapted for dynamic theming)
// ═════════════════════════════════════════════════════════════════════════════

class _PremiumInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
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
    this.suffixIcon,
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
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LoginScreen
// ═════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Restored your exact backend logic for routing and loading sessions
  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    HapticService.instance.medium();

    final result = await context.read<AuthService>().login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.errorMessage;
      });
    } else {
      await SessionService.instance.load(AuthService.instance.userId!);
      await SessionService.instance
          .syncFromBackend(AuthService.instance.token!);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
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
              // App bar
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
                          'ELOQUA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.loginTitle,
                        style: isParadise
                            ? GoogleFonts.playfairDisplay(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                height: 1.1,
                              )
                            : tt.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back.',
                        style:
                            tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
                            _PremiumInputField(
                              label: AppStrings.loginEmail,
                              placeholder: 'hello@example.com',
                              controller: _emailCtrl,
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _PremiumInputField(
                              label: AppStrings.loginPassword,
                              placeholder: '••••••••',
                              controller: _passCtrl,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  HapticService.instance.light();
                                  setState(() => _obscure = !_obscure);
                                },
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 18,
                                ),
                              ),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  HapticService.instance.light();
                                  Navigator.pushNamed(
                                      context, '/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: cs.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppStrings.loginForgot,
                                  style: tt.labelMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Sign In button
                            GestureDetector(
                              onTap: _loading ? null : _submit,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: _loading
                                      ? cs.primary.withOpacity(0.5)
                                      : cs.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _loading
                                      ? const []
                                      : [
                                          BoxShadow(
                                            color: cs.primary.withOpacity(0.3),
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
                                          AppStrings.loginBtn,
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

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: cs.outlineVariant,
                              thickness: 0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Divider(
                              color: cs.outlineVariant,
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),

                      // Sign up link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.loginNoAccount + "  ",
                              style: tt.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticService.instance.light();
                                Navigator.pushReplacementNamed(
                                    context, '/register');
                              },
                              child: Text(
                                'Create account',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer
                      Center(
                        child: Text(
                          'Eloqua Digital Consortium © 2026',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 9,
                            letterSpacing: 0.8,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

// ═════════════════════════════════════════════════════════════════════════════
// Social Button
// ═════════════════════════════════════════════════════════════════════════════

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: cs.onSurface),
                    if (label.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: context.tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                )
              : Text(
                  label,
                  style: context.tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
