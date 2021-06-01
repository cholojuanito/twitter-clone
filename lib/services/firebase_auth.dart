import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/util/auth_util.dart';

class FirebaseAuthenticationService extends AuthenticationService {
  static final FirebaseAuthenticationService _instance =
      FirebaseAuthenticationService._internal();
  factory FirebaseAuthenticationService() {
    // This makes AppState a singleton but is still callable with 'new'
    return _instance;
  }
  FirebaseAuthenticationService._internal();

  Api _api;
  FirebaseAuth _fbAuth = FirebaseAuth.instance;
  static const String _fakeEmailDomain = '@twitter-clone-nomail.net';
  static const String _invalidEmailCode = 'ERROR_INVALID_EMAIL';
  static const String _invalidPasswordCode = 'ERROR_WRONG_PASSWORD';
  static const String _invalidUserCode = 'ERROR_USER_NOT_FOUND';
  static const String _weakPasswordCode = 'ERROR_WEAK_PASSWORD';
  static const String _emailInUseCode = 'ERROR_EMAIL_ALREADY_IN_USE';
  static const Map<String, String> _codeRespMap = {
    _invalidEmailCode: 'Incorrect alias or password',
    _invalidPasswordCode: 'Incorrect alias or password',
    _invalidUserCode: 'That alias does not exist. Please sign up first',
    _weakPasswordCode: 'Your password does not meet the security requirements',
    _emailInUseCode: 'A user is already using that alias',
  };

  @override
  set api(Api api) => _api = api;

  @override
  Future<User> getCurrentUserAsync() async {
    var fbUser = await _fbAuth.currentUser();
    if (fbUser == null) {
      return null;
    }
    this.currUser = await _api.getUserById(fbUser.uid);
    return this.currUser;
  }

  @override
  User getCurrentUserSync() {
    return this.currUser;
  }

  @override
  Future<AuthResponse> signIn(String alias, String password) async {
    AuthResult result;
    AuthResponse resp;

    try {
      result = await _fbAuth.signInWithEmailAndPassword(
          email: alias + _fakeEmailDomain, password: password);
    } on PlatformException catch (error) {
      print('Error ${error.toString()}');
      resp = AuthResponse(-1, '');

      switch (error.code) {
        case _invalidEmailCode:
          resp.message = _codeRespMap[_invalidEmailCode];
          break;
        case _invalidUserCode:
          resp.message = _codeRespMap[_invalidUserCode];
          break;
        case _invalidPasswordCode:
          resp.message = _codeRespMap[_invalidPasswordCode];
          break;
        case _weakPasswordCode:
          resp.message = _codeRespMap[_weakPasswordCode];
          break;
        default:
          resp.message = 'An error occurred: ${error.message}';
      }

      return resp;
    }

    if (result.user != null && await result.user.getIdToken() != null) {
      this.currUser = await _api.getUserById(result.user.uid);
      // Build state?
      resp = AuthResponse(0, 'Successfully logged in');
    } else {
      resp = AuthResponse(-1, 'Error with something weird');
    }

    return resp;
  }

  @override
  Future<AuthResponse> signUp(String name, String alias, String password,
      {String profilePicPath}) async {
    AuthResult result;
    AuthResponse resp;

    AuthResponse _passResp = isValidPassword(password);
    if (_passResp.status == -1) {
      return _passResp;
    }

    try {
      result = await _fbAuth.createUserWithEmailAndPassword(
          email: alias + _fakeEmailDomain, password: password);
    } on PlatformException catch (error) {
      print('Error ${error.toString()}');
      resp = AuthResponse(-1, '');

      switch (error.code) {
        case _invalidEmailCode:
          resp.message = _codeRespMap[_invalidEmailCode];
          break;
        case _weakPasswordCode:
          resp.message = _codeRespMap[_weakPasswordCode];
          break;
        case _emailInUseCode:
          resp.message = _codeRespMap[_emailInUseCode];
          break;
        default:
          resp.message = 'An error occurred: ${error.message}';
      }

      return resp;
    }

    if (result.user != null && await result.user.getIdToken() != null) {
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = name;
      await result.user.updateProfile(updateInfo);
      User newUser = profilePicPath != null
          ? User(alias, name,
              id: result.user.uid,
              profilePic: Media(profilePicPath, MediaType.Image))
          : User(
              alias,
              name,
              id: result.user.uid,
            );
      this.currUser = await _api.createUser(newUser);
      // Build state?
      resp = AuthResponse(0, 'Successfully logged in');
    } else {
      resp = AuthResponse(-1, 'Error with something weird');
    }

    return resp;
  }

  @override
  void signOut() {
    this.currUser = null;
    this._fbAuth.signOut();
    notifyListeners();
  }

  @override
  void updateCurrUser() {
    // TODO: implement updateCurrUser
  }

  Future<AuthResponse> isUniqueAlias(String alias) async {
    bool isUnique = await _api.isUniqueAlias(alias);
    return isUnique
        ? AuthResponse(0, 'Valid alias')
        : AuthResponse(-1, 'That alias is already taken');
  }
}
