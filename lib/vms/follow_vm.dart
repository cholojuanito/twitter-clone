import 'package:flutter/widgets.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/vms/base_vm.dart';

class FollowingVM extends BaseVM with ChangeNotifier {
  Api api;
  User loggedInUser;
  User otherUser;
  Following theFollowing;

  FollowingVM(this.loggedInUser, this.otherUser, this.api, {this.theFollowing});

  void toggleFollowStatus(bool follow) {
    if (follow) {
      api.follow(loggedInUser.id, otherUser.id);
    } else {
      api.unfollow(loggedInUser.id, otherUser.id);
    }
  }

  bool isCurrUserFollowing() {
    for (var f in this.loggedInUser.following) {
      if (f.followeeId == this.otherUser.id) {
        return true;
      }
    }
    return false;
  }
}
