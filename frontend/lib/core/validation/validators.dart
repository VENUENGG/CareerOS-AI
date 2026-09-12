import 'package:flutter/material.dart';
import '../widgets/app_text_field.dart';

class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$"
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value == null) return null;
    if (value.length > max) {
      return '$fieldName must be no more than $max characters';
    }
    return null;
  }

  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? integer(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid integer';
    }
    return null;
  }

  static String? positive(String? value, {String fieldName = 'This field'}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;
    final num = double.parse(value!.trim());
    if (num <= 0) {
      return '$fieldName must be positive';
    }
    return null;
  }

  static String? nonNegative(String? value, {String fieldName = 'This field'}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;
    final num = double.parse(value!.trim());
    if (num < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? range(String? value, double min, double max, {String fieldName = 'This field'}) {
    final numError = numeric(value, fieldName: fieldName);
    if (numError != null) return numError;
    final num = double.parse(value!.trim());
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  static String? url(String? value, {String fieldName = 'URL'}) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{4,10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? year(String? value, {int minYear = 1900, int maxYear = 2100}) {
    final intError = integer(value, fieldName: 'Year');
    if (intError != null) return intError;
    final year = int.parse(value!.trim());
    if (year < minYear || year > maxYear) {
      return 'Enter a year between $minYear and $maxYear';
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    return null;
  }

  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;
    final parsed = DateTime.parse(value!.trim());
    if (parsed.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  static String? combine(List<String?> Function() validators) {
    final errors = validators().where((e) => e != null).cast<String>().toList();
    if (errors.isEmpty) return null;
    return errors.join('\n');
  }

  static FormFieldValidator<String> compose(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLengthValidator(int min, {String fieldName = 'This field'}) {
    return (value) => minLength(value, min, fieldName: fieldName);
  }

  static FormFieldValidator<String> maxLengthValidator(int max, {String fieldName = 'This field'}) {
    return (value) => maxLength(value, max, fieldName: fieldName);
  }

  static FormFieldValidator<String> rangeValidator(double min, double max, {String fieldName = 'This field'}) {
    return (value) => range(value, min, max, fieldName: fieldName);
  }

  static FormFieldValidator<String> positiveValidator({String fieldName = 'This field'}) {
    return (value) => positive(value, fieldName: fieldName);
  }

  static FormFieldValidator<String> nonNegativeValidator({String fieldName = 'This field'}) {
    return (value) => nonNegative(value, fieldName: fieldName);
  }

  static FormFieldValidator<String> integerValidator({String fieldName = 'This field'}) {
    return (value) => integer(value, fieldName: fieldName);
  }

  static FormFieldValidator<String> numericValidator({String fieldName = 'This field'}) {
    return (value) => numeric(value, fieldName: fieldName);
  }

  static FormFieldValidator<String> yearValidator({int minYear = 1900, int maxYear = 2100}) {
    return (value) => year(value, minYear: minYear, maxYear: maxYear);
  }
}

class ValidatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final List<FormFieldValidator<String>> validators;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const ValidatedFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validators,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<ValidatedFormField> createState() => _ValidatedFormFieldState();
}

class _ValidatedFormFieldState extends State<ValidatedFormField> {
  String? _error;
  bool _touched = false;

  void _validate() {
    if (!_touched) return;
    for (final validator in widget.validators) {
      final error = validator(widget.controller.text);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: _touched ? _error : null,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: (value) {
        widget.onChanged?.call(value);
        _validate();
      },
      onSubmitted: (value) {
        _touched = true;
        _validate();
        widget.onSubmitted?.call(value);
      },
      onTap: () => setState(() => _touched = true),
      suffixIcon: widget.suffixIcon,
      prefixIcon: widget.prefixIcon,
      autovalidateMode: AutovalidateMode.disabled,
    );
  }
}