import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/vms/follow_vm.dart';

class UserListItem extends StatefulWidget {
  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  FollowingVM _followingVM;

  Widget _unfollowButton() {
    return RaisedButton(
      onPressed: () {
        _followingVM.toggleFollowStatus(false);
      },
      child: Text('Unfollow'),
    );
  }

  Widget _followButton() {
    return RaisedButton(
      onPressed: () {
        _followingVM.toggleFollowStatus(true);
      },
      child: Text('Follow'),
    );
  }

  Widget _buildButton() {
    if (_followingVM.isCurrUserFollowing()) {
      return _unfollowButton();
    } else {
      return _followButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowingVM>(
      builder: (context, vm, _) {
        this._followingVM = vm;
        return ListTile(
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundImage:
                  vm.otherUser.profilePic.route == User.defaultProfileURL
                      ? AssetImage(vm.otherUser.profilePic.route)
                      : FileImage(File(vm.otherUser.profilePic.route)),
            ),
          ),
          title: Text('${vm.otherUser.fullName}'),
          subtitle: Text('@${vm.otherUser.alias}'),
          trailing: _buildButton(),
        );
      },
    );
  }
}
