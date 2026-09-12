import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/app_providers.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool register = false;
  bool obscure = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: AppMotion.medium, vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: AppMotion.decelerate));
    _slideAnimation = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: AppMotion.decelerate));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animationController.reverse().then((_) {
      setState(() {
        register = !register;
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
      });
      _animationController.forward();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = register
        ? await auth.register(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          )
        : await auth.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted || !ok) return;

    if (register) {
      _toggleMode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created. Sign in to continue.'),
            backgroundColor: AppColors.successContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    } else {
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.xxxl),
                        _buildForm(auth),
                        const SizedBox(height: AppSpacing.xl),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CareerOS', style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.md),
        Text(
          register ? 'Build your career profile.' : 'Welcome back to your career OS.',
          style: AppTypography.bodyLarge.muted(),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return AppCard(
      padding: AppSpacing.xxlAll,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (register) ...[
              Row(
                children: [
                  Expanded(
                    child: ValidatedFormField(
                      controller: _firstNameController,
                      label: 'First name',
                      validators: [Validators.required, Validators.minLengthValidator(2, fieldName: 'First name')],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ValidatedFormField(
                      controller: _lastNameController,
                      label: 'Last name',
                      validators: [Validators.required, Validators.minLengthValidator(2, fieldName: 'Last name')],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ValidatedFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validators: [Validators.required, Validators.email],
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ValidatedFormField(
              controller: _passwordController,
              label: 'Password',
              hint: register ? 'At least 8 characters' : 'Enter your password',
              obscureText: obscure,
              textInputAction: register ? TextInputAction.next : TextInputAction.done,
              validators: [
                Validators.required,
                if (register) Validators.minLengthValidator(8, fieldName: 'Password'),
              ],
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textTertiary),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              ErrorBanner(
                message: auth.error!,
                onDismiss: () => auth.error = null,
                icon: Icons.error_outline_rounded,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: register ? 'Create account' : 'Sign in',
              onPressed: auth.loading ? null : _submit,
              loading: auth.loading,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: TextButton(
        onPressed: _toggleMode,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          foregroundColor: AppColors.primary,
        ),
        child: Text(
          register ? 'Already have an account? Sign in' : 'New to CareerOS? Create account',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}