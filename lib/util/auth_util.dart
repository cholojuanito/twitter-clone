const int MIN_PASSWORD_LEN = 8;
const int MAX_PASSWORD_LEN = 16;

RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

RegExp _passwordRegex =
    RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%&*?]).{8,16}$');

AuthResponse isValidEmail(String email) {
  bool matches = _emailRegex.hasMatch(email);
  return matches
      ? AuthResponse(0, 'Valid')
      : AuthResponse(-1, 'Not a valid email');
}

/// A valid password must meet the following:
/// * Be between 8 and 16 characters
/// * Contain at least:
/// * 1. one number
/// * 2. one uppercase letter
/// * 3. one lower case letter
/// * 4. one special character from this list => [!, @, #, $, %, &, *, ?]
AuthResponse isValidPassword(String password) {
  if (password.length < MIN_PASSWORD_LEN ||
      password.length > MAX_PASSWORD_LEN) {
    return AuthResponse(
      -1,
      'Password must be between 8 and 16 characters',
    );
  }

  bool matches = _passwordRegex.hasMatch(password);
  if (matches) {
    return AuthResponse(0, 'Valid');
  } else {
    return AuthResponse(
      -1,
      'Password must contain:\n- a number\n- an upper and lower case letter\n- a special character: !, @, #, \$, %, &, *, ?',
    );
  }
}

class AuthResponse {
  int status;
  String _message;

  AuthResponse(this.status, this._message);

  String get message => this._message;

  set message(String m) => this._message = m;
}
