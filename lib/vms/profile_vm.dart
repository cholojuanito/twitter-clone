import 'package:flutter/widgets.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/vms/base_vm.dart';

class ProfileVM extends BaseVM with ChangeNotifier {
  Api _api;
  User user;

  ProfileVM(this.user, this._api);

  void changeProfilePic(String imagePath) {
    this.user.changeProfilePic(imagePath);
    notifyListeners();
  }

  @override
  void setLoadingState(bool state) {
    super.setLoadingState(state);
    notifyListeners();
  }
}
