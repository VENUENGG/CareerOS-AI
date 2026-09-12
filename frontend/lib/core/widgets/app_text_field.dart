import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design/design.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _focused = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _currentError = widget.errorText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() => _currentError = widget.errorText);
    }
  }

  void _onFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _currentError != null && _currentError!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.danger
        : _focused
            ? AppColors.primary
            : AppColors.border;

    final suffixWidgets = <Widget>[];
    if (widget.suffixIcon != null) suffixWidgets.add(widget.suffixIcon!);
    if (widget.suffix != null) suffixWidgets.add(widget.suffix!);
    if (widget.maxLength != null && widget.controller != null) {
      suffixWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Text(
            '${widget.controller!.text.length}/${widget.maxLength}',
            style: AppTypography.caption,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autovalidateMode: widget.autovalidateMode,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.placeholder),
            helperText: widget.helperText,
            helperStyle: AppTypography.bodySmall.muted(),
            errorText: _currentError,
            errorStyle: AppTypography.bodySmall.danger(),
            errorMaxLines: 3,
            filled: true,
            fillColor: widget.enabled ? AppColors.surface : AppColors.surfaceElevated.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            prefixIcon: widget.prefixIcon != null
                ? Padding(padding: const EdgeInsets.all(AppSpacing.md), child: widget.prefixIcon)
                : widget.prefix != null
                    ? Padding(padding: const EdgeInsets.all(AppSpacing.md), child: widget.prefix)
                    : null,
            suffixIcon: suffixWidgets.isNotEmpty
                ? Row(mainAxisSize: MainAxisSize.min, children: suffixWidgets)
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(borderRadius: AppRadii.input, borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: borderColor, width: _focused || hasError ? 1.5 : 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.danger, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.border, width: 0.5),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class AppTextFieldMultiline extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const AppTextFieldMultiline({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.minLines = 3,
    this.maxLines = 6,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}

class AppSelectField<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T?>? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const AppSelectField({
    super.key,
    required this.value,
    required this.items,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          value: value, // ignore: deprecated_member_use
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: AppTypography.bodySmall.muted(),
            errorText: errorText,
            errorStyle: AppTypography.bodySmall.danger(),
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceElevated.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            prefixIcon: prefixIcon != null ? Padding(padding: const EdgeInsets.all(AppSpacing.md), child: prefixIcon) : null,
            border: OutlineInputBorder(borderRadius: AppRadii.input, borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.border, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.danger, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.input,
              borderSide: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          style: AppTypography.bodyLarge,
          dropdownColor: AppColors.surface,
          borderRadius: AppRadii.card,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
          selectedItemBuilder: (context) => items.map((item) => Text(item.value.toString(), style: AppTypography.bodyLarge)).toList(),
        ),
      ],
    );
  }
}