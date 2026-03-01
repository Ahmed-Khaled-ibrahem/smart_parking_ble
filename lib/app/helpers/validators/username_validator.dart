String? verifyUserName(String? value){
  if (value == null || value.isEmpty) {
    return 'Please enter your username';
  }
  if (value.length < 3) {
    return 'Username must be at least 3 characters long';
  }
  if (value.length > 15) {
    return 'Username must be less than 15 characters long';
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Username can only contain letters, numbers, and underscores';
  }
  if (value.contains(' ')) {
    return 'Username cannot contain spaces';
  }
  return null;
}