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

  Future<AuthResponse> login(email, password) async {
    setLoadingState(true);
    AuthResponse retVal = await this._authService.signIn(email, password);

    setLoadingState(false);
    return retVal;
  }

  Future<bool> signUp(email, alias, password) async {
    setLoadingState(true);
    bool retVal;
    // Create a User/Session
    AuthResponse res = await this._authService.signUp(email, alias, password);
    switch (res.status) {
      case 0:
        retVal = true;
        break;
      case -1:
      case 1:
      default:
        retVal = false;
        break;
    }

    setLoadingState(false);
    return retVal;
  }

  void signOut() {
    this._authService.signOut();
  }
}
