import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/vms/follow_vm.dart';

class UserListItem extends StatefulWidget {
  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FollowingVM>(
      builder: (context, vm, _) {
        return ListTile(
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: CircleAvatar(
              child: vm.otherUser.profilePic.route == User.defaultProfileURL
                  ? Image.asset(vm.otherUser.profilePic.route)
                  : Image.network(vm.otherUser.profilePic.route),
            ),
          ),
          title: Text('${vm.otherUser.fullName}'),
          subtitle: Text('@${vm.otherUser.alias}'),

          // TODO figure out following button functionality
          trailing: MaterialButton(
            onPressed: () {},
            child: Text('Follow'),
          ),
        );
      },
    );
  }
}
