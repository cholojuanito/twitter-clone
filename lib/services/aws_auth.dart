import 'package:twitter/dummy_data.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/authentication.dart';
import 'package:twitter/services/aws_api.dart';
import 'package:twitter/util/auth_util.dart';
import 'package:uuid/uuid.dart';

class AWSAuthenticationService extends AuthenticationService {
  AWSAuthenticationService();

  // TODO get rid of this, it is solely for the dummy data
  void updateCurrUser() {
    // updateUser(this.currUser.id);
    notifyListeners();
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

    try {
      this.currUser = await AWSTwitterApi.getInstance().getUserByAlias(alias);
    } on StateError catch (e) {
      return AuthResponse(
          -1, 'No user exists with that alias. Try creating an account.');
    }
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
    bool resp = await AWSTwitterApi.getInstance().createUser(newuser);

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
