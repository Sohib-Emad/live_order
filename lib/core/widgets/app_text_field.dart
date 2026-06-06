// lib/shared/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:live_order/core/constants/app_design.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppDesign.body(
              color: AppDesign.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDesign.space8),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          cursorColor: AppDesign.primary,
          style: AppDesign.body(color: AppDesign.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppDesign.body(color: AppDesign.textSecondary.withOpacity(0.6)),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDesign.space16,
              vertical: AppDesign.space16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              borderSide: const BorderSide(color: AppDesign.border, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              borderSide: const BorderSide(color: AppDesign.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              borderSide: const BorderSide(color: AppDesign.danger, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              borderSide: const BorderSide(color: AppDesign.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
