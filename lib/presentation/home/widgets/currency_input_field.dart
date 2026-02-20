import 'package:flutter/material.dart';

class CurrencyInputField extends StatelessWidget {
  const CurrencyInputField({
    super.key,
    required this.label,
    required this.prefix,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String prefix;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
