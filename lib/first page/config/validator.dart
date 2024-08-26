class Validation {
  static String? validateEmail(String? value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (!regex.hasMatch(value)) {
      return 'Password must be at least 8 characters long, include an \nuppercase letter, a lowercase letter, a number, and a special \ncharacter';
    }
    return null;
  }
}
