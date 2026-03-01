String? verifyBirthDay(DateTime? value) {
  if (value == null) {
    return 'Please select your date of birth';
  }
  final age = DateTime.now().difference(value).inDays ~/ 365;
  if (age < 15) {
    return 'You must be at least 15 years old';
  }
  return null;
}
