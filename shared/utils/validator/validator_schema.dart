typedef ValidationRule = String? Function(dynamic value);

class ValidatorSchema {
  ValidatorSchema(this.rules);
  final Map<String, List<ValidationRule>> rules;

  Map<String, String>? validate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    rules.forEach((field, validators) {
      final value = data[field];

      for (final rule in validators) {
        final result = rule(value);
        if (result != null) {
          errors[field] = result;
          break;
        }
      }
    });

    return errors.isEmpty ? null : errors;
  }
}
