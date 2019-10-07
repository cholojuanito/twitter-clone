import 'package:twitter/models/following.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/authentication.dart';

import 'base_vm.dart';

class UserListItemVM extends BaseVM {
  User user;
  AuthenticationService _service;

  UserListItemVM(this.user, this._service);
}
