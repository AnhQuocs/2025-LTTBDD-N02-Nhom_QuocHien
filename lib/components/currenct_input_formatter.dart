import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Parse -> int
    final number = int.parse(digits);

    // Format VND
    final newString = NumberFormat.decimalPattern('vi').format(number);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length - 2), // caret đứng trước ₫
    );
  }
}