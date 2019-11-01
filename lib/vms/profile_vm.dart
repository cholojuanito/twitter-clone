import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/vms/base_vm.dart';

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
