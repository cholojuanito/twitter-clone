import 'package:uuid/uuid.dart';

class Following {
  String id = Uuid().v4();
  String followerId;
  String followeeId;
  DateTime startDate;
  bool isActive;

  Following(this.followerId, this.followeeId,
      {this.id, this.isActive = true, this.startDate}) {
    if (this.startDate == null) {
      this.startDate = DateTime.now();
    }
  }
}
