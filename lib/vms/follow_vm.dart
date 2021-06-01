import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/following.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/vms/base_vm.dart';

class FollowingVM extends BaseVM with ChangeNotifier {
  Api api;
  User loggedInUser;
  User otherUser;
  Following theFollowing;

  FollowingVM(this.loggedInUser, this.otherUser, this.api, {this.theFollowing});

  void toggleFollowStatus(bool follow) {
    if (follow) {
      api.createFollow(Following(loggedInUser.id, otherUser.id));
    } else {
      api.updateFollow(Following(loggedInUser.id, otherUser.id), 'add');
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
