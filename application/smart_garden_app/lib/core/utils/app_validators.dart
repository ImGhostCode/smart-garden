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

  static String? required(dynamic value, {String? fieldName}) {
    if (value == null || value.toString().trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? numberOnly(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (num.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }
    return null;
  }

  static String? positiveNum(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (num.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    } else if (num.parse(value) <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }
    return null;
  }

  static String? positiveInt(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    } else if (int.parse(value) <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }
    return null;
  }

  // Greater than or equal to zero
  static String? nonNegativeInt(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    } else if (int.parse(value) < 0) {
      return '${fieldName ?? 'This field'} must be greater than or equal to zero';
    }
    return null;
  }

  // Greater than or equal to zero
  static String? nonNegativeNum(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (num.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    } else if (num.parse(value) < 0) {
      return '${fieldName ?? 'This field'} must be greater than or equal to zero';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min character(s)';
    }
    return null;
  }

  static String? durationFormat(
    String? value, {
    String? fieldName = 'Duration',
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final durationRegExp = RegExp(r'^(\d+h)?(\d+m)?(\d+s)?$');
    if (!durationRegExp.hasMatch(value)) {
      return '${fieldName ?? 'This field'} must be in format like "1h30m"';
    }
    // Hours, minutes, seconds should not all be zero
    final match = durationRegExp.firstMatch(value);
    final hours = match?.group(1);
    final minutes = match?.group(2);
    final seconds = match?.group(3);
    final allZero =
        (hours == '0h' || hours == null) &&
        (minutes == '0m' || minutes == null) &&
        (seconds == '0s' || seconds == null);
    if (allZero) {
      return '${fieldName ?? 'This field'} must be greater than zero';
    }
    return null;
  }

  // Validates hour input (0-23)
  static String? validHour(String? value, {String? fieldName = 'Hour'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^\d{1,2}$');
    if (!regex.hasMatch(value)) {
      return '${fieldName ?? 'This field'} is invalid';
    }
    final hour = int.tryParse(value);
    if (hour == null || hour < 0 || hour > 23) {
      return '${fieldName ?? 'This field'} must be between 0 and 23';
    }
    return null;
  }

  static String? validMinute(String? value, {String? fieldName = 'Minute'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^\d{1,2}$');
    if (!regex.hasMatch(value)) {
      return '${fieldName ?? 'This field'} is invalid';
    }
    final minute = int.tryParse(value);
    if (minute == null || minute < 0 || minute > 59) {
      return '${fieldName ?? 'This field'} must be between 0 and 59';
    }
    return null;
  }

  // Topic prefix cannot contain spaces or characters: [$#*>+/]
  static String? validTopic(
    String? value, {
    String? fieldName = 'Topic prefix',
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^[^ $#*>+/]+$');
    if (!regex.hasMatch(value)) {
      return '${fieldName ?? 'This field'} cannot contain spaces or \$#*>+/';
    }
    return null;
  }

  // Pin must be greater than or equal to 0
  static String? pin(String? value, {String? fieldName = 'Pin'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^\d{1,2}$');
    if (!regex.hasMatch(value)) {
      return '${fieldName ?? 'This field'} is invalid';
    }
    final pin = int.tryParse(value);
    if (pin == null || pin < 0) {
      return '${fieldName ?? 'This field'} must be greater than or equal to 0';
    }
    return null;
  }
}
