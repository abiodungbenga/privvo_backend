import 'validator_schema.dart';

class ValidationRules {
  static ValidationRule required() {
    return (value) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        return 'This field is required';
      }
      return null;
    };
  }

  static ValidationRule email() {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    return (value) {
      if (value == null) return null;
      if (value is! String || !regex.hasMatch(value)) {
        return 'Invalid email address';
      }
      return null;
    };
  }

  static ValidationRule minLength(int length) {
    return (value) {
      if (value == null) return null;
      if (value is String && value.length < length) {
        return 'Must be at least $length characters';
      }
      return null;
    };
  }
}
