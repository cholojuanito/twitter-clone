import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/vms/base_vm.dart';
import 'package:twitter/services/authentication.dart';
import 'package:twitter/util/auth_util.dart';

class AuthVM extends BaseVM {
  AuthenticationService _authService;

  AuthVM(this._authService);

  User getCurrentUser() {
    return this._authService.getCurrentUser();
  }

  Future<AuthResponse> login(String name, String password) async {
    setLoadingState(true);
    AuthResponse retVal = await this._authService.signIn(name, password);

    setLoadingState(false);
    return retVal;
  }

  Future<AuthResponse> signUp(String name, String alias, String password,
      {String profilePicPath}) async {
    setLoadingState(true);
    // Create a User/Session
    AuthResponse retVal = await this
        ._authService
        .signUp(name, alias, password, profilePicPath: profilePicPath);

    setLoadingState(false);
    return retVal;
  }

  void signOut() {
    this._authService.signOut();
  }
}