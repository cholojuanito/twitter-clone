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

  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      json['followerId'] as String,
      json['followeeId'] as String,
      id: json['id'] as String,
      isActive: json['isActive'] as bool,
      startDate: DateTime.parse(json['startDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'followerId': followerId,
        'followeeId': followeeId,
        'isActive': isActive,
        'startDate': startDate?.toIso8601String(),
      };
}
