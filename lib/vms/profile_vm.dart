import 'package:flutter/widgets.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/vms/base_vm.dart';

class ProfileVM extends BaseVM with ChangeNotifier {
  User user;

  ProfileVM(this.user);

  @override
  void setLoadingState(bool state) {
    super.setLoadingState(state);
    notifyListeners();
  }
}
