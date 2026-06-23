abstract final class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    // Accepts formats: +2348012345678, 08012345678, 8012345678
    final regex = RegExp(r'^(\+?234|0)?[789]\d{9}$');
    if (!regex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? label}) {
    if (value == null || value.length < min) {
      return '${label ?? 'This field'} must be at least $min characters.';
    }
    return null;
  }

  // Chains validators — returns the first non-null error.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
