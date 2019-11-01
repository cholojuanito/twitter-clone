import 'package:twitter_clone/dummy_data.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/util/auth_util.dart';
import 'package:uuid/uuid.dart';

import 'api.dart';

class AWSAuthenticationService extends AuthenticationService {
  Api _api;
  AWSAuthenticationService();

  @override
  set api(Api api) => _api = api;

  // TODO get rid of this, it is solely for propogating data changes
  void updateCurrUser() {
    _api.getUserById(this.currUser.id).then((newUser) {
      this.currUser = newUser;
      notifyListeners();
    });
  }

  @override
  User getCurrentUser() {
    return this.currUser;
  }

  @override
  Future<AuthResponse> signIn(String alias, String password) async {
    // AuthResponse _passResp = isValidPassword(password);

    // if (_passResp.status == -1) {
    //   return _passResp;
    // }

    var user = await _api.getUserByAlias(alias);
    if (user == null) {
      return AuthResponse(
          -1, 'No user exists with that alias. Try creating an account.');
    }

    // Create session
    this.currUser = user;

    notifyListeners();

    return AuthResponse(0, 'Logging in...');
  }

  @override
  Future<AuthResponse> signUp(String name, String alias, String password,
      {String profilePicPath}) async {
    AuthResponse _aliasResp = await isUniqueAlias(alias);
    AuthResponse _passResp = isValidPassword(password);

    if (_aliasResp.status == -1) {
      return _aliasResp;
    }

    // if (_passResp.status == -1) {
    //   return _passResp;
    // }

    User newuser = User(alias, name, id: Uuid().v4());
    if (profilePicPath != null) {
      newuser.changeProfilePic(profilePicPath);
    }

    User resp = await _api.createUser(newuser);

    // Create session
    this.currUser = newuser;

    notifyListeners();
    return AuthResponse(0, 'Welcome ${newuser.alias}!');
  }

  Future<AuthResponse> isUniqueAlias(String alias) async {
    bool isUnique = await _api.isUniqueAlias(alias);
    return isUnique
        ? AuthResponse(0, 'Valid alias')
        : AuthResponse(-1, 'That alias is already taken');
  }

  @override
  void signOut() {
    this.currUser = null;
    notifyListeners();
  }
}
