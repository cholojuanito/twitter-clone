import 'package:flutter/cupertino.dart';

import 'package:twitter/models/user.dart';
import 'package:twitter/util/auth_util.dart';

abstract class AuthenticationService extends ChangeNotifier {
  User currUser;

  /// Gets the currently logged in User
  User getCurrentUser();

  // TODO get rid of this
  void updateCurrUser();

  /// Signs a User into a new session
  Future<AuthResponse> signIn(
    String name,
    String password,
  );

  /// Signs up a new User for the application
  Future<AuthResponse> signUp(String name, String alias, String password,
      {String profilePicPath});

  /// Ends a Users session
  void signOut();
}
