import 'package:twitter/dummy_data.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/authentication.dart';
import 'package:twitter/util/auth_util.dart';
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
    this.currUser = user;

    notifyListeners();

    return AuthResponse(0, 'Logging in...');
  }

  @override
  Future<AuthResponse> signUp(String name, String alias, String password,
      {String profilePicPath}) async {
    AuthResponse _aliasResp = isUniqueAlias(alias);
    AuthResponse _passResp = isValidPassword(password);

    if (_aliasResp.status == -1) {
      return _aliasResp;
    }

    // if (_passResp.status == -1) {
    //   return _passResp;
    // }

    User newuser = User(Uuid().v4(), alias, name);
    if (profilePicPath != null) {
      newuser.changeProfilePic(profilePicPath);
    }
    bool resp = await _api.createUser(newuser);

    this.currUser = newuser;
    notifyListeners();
    return AuthResponse(0, 'Welcome ${newuser.alias}!');
  }

  AuthResponse isUniqueAlias(String alias) {
    for (var user in allUsers) {
      if (user.alias == alias) {
        return AuthResponse(-1, 'That alias is already taken');
      }
    }
    return AuthResponse(0, 'Valid alias');
  }

  @override
  void signOut() {
    this.currUser = null;
    notifyListeners();
  }
}
