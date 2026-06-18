import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: Ensure your theme_manager_ext.dart is imported here or in a global scope
// import '../../core/theme/theme_manager_ext.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/haptic_service.dart';
import 'login_screen.dart';
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
// RegisterScreen
// ═════════════════════════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true; // Added specifically for the confirm field
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // Restored your exact backend logic for registration
  Future<void> _register() async {
    // Client-side confirm check since service doesn't take a confirm param
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    HapticService.instance.medium();
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthService>().register(
          name: _name.text,
          email: _email.text,
          password: _pass.text,
        );

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.errorMessage;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerSuccess)),
      );
      Navigator.pushReplacementNamed(context, '/login');
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      const SizedBox(height: 12),

                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: cs.primary.withOpacity(0.2), width: 0.5),
                        ),
                        child: Text(
                          'Master the Message',
                          style: tt.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        AppStrings.registerTitle,
                        style: isParadise
                            ? GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              )
                            : tt.headlineLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Unlock the full potential of your message.',
                        style:
                            tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 28),

                      // Card
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
                              label: AppStrings.registerName,
                              placeholder: 'Your name here',
                              controller: _name,
                              prefixIcon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _PremiumInputField(
                              label: AppStrings.registerEmail,
                              placeholder: 'hello@creative.com',
                              controller: _email,
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _PremiumInputField(
                              label: AppStrings.registerPass,
                              placeholder: '••••••••',
                              controller: _pass,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.next,
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
                            const SizedBox(height: 16),
                            _PremiumInputField(
                              label: AppStrings.registerConfirm,
                              placeholder: '••••••••',
                              controller: _confirm,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _register(),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  HapticService.instance.light();
                                  setState(
                                      () => _obscureConfirm = !_obscureConfirm);
                                },
                                child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 18,
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _loading ? null : _register,
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
                                          AppStrings.registerBtn,
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
                      const SizedBox(height: 20),

                      // Login Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppStrings.registerHasAccount + " ",
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              TextSpan(
                                text: 'Log in',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    HapticService.instance.light();
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          'By joining, you agree to the Eloqua Terms of Play\nand Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                            height: 1.7,
                          ),
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
