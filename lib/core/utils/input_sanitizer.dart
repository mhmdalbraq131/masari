class InputSanitizer {
  static String cleanText(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String cleanPhone(String input) {
    return input.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }

  static String cleanNumber(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '').trim();
  }
}
