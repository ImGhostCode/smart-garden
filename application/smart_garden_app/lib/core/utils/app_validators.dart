class AppValidators {
  // Hàm kết hợp nhiều validator
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null; // All is valid
    };
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? numberOnly(String? value, String? fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (num.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }
    return null;
  }

  static String? minLength(String? value, int min, String? fieldName) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min character(s)';
    }
    return null;
  }
}
