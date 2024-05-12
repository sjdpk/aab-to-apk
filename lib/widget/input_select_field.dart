
import 'package:flutter/material.dart';

class BuildSelectEnterField extends StatelessWidget {
  final Function()? onTap;
  final String hintText;
  final bool isEnabled;
  final bool isPassword;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const BuildSelectEnterField({
    super.key,
    this.onTap,
    this.controller,
    required this.hintText,
    this.isEnabled = false,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: isEnabled,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
          // decoration for the text field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
