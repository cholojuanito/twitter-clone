import 'package:uuid/uuid.dart';

class Following {
  String id = Uuid().v4();
  String followerId;
  String followeeId;
  DateTime startDate;

  Following(this.id, this.followerId, this.followeeId, {this.startDate}) {
    if (this.startDate == null) {
      this.startDate = DateTime.now();
    }
  }
}
