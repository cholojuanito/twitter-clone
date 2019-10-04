import 'package:flutter/widgets.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/vms/base_vm.dart';

class FollowingVM extends BaseVM with ChangeNotifier {
  User _loggedInUser;
  User otherUser;
  Following theFollowing;

  FollowingVM(this._loggedInUser, this.otherUser, {this.theFollowing});

  // bool getFollowStatus();

  void toggleFollowStatus() {}
}
