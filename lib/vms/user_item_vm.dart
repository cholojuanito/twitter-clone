import 'package:twitter_clone/models/following.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/authentication.dart';

import 'base_vm.dart';

class UserListItemVM extends BaseVM {
  User user;
  AuthenticationService _service;

  UserListItemVM(this.user, this._service);
}
