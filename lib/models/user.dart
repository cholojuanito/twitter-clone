import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/tweet_collections.dart';
import 'package:twitter/models/following.dart';
import 'package:uuid/uuid.dart';

class User with ChangeNotifier {
  String id = Uuid().v4();
  String alias;

  String _fullName;
  String get fullName => _fullName;
  set fullName(String name) {
    this._fullName = name;
    notifyListeners();
  }

  Media profilePic = Media(_defaultProfileURL, MediaType.Image);
  void changeProfilePic(String path) {
    this.profilePic = Media(path, MediaType.Image);
    notifyListeners();
  }

  List<Following> followers;
  List<Following> following;
  Feed feed;
  Story story;
  DateTime created = DateTime.now();

  static const String _defaultProfileURL = '';

  User(
    this.id,
    this.alias,
    this._fullName, {
    this.profilePic,
    this.followers,
    this.following,
    this.feed,
    this.story,
    this.created,
  }) {
    if (this.created == null) {
      this.created = DateTime.now();
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // List<Following> _followers = [];
    // var jsonFollowers = json['followers'];
    // List<Following> _following = [];

    return User(
      json['id'] as String,
      json['alias'] as String,
      json['fullName'] as String,
      profilePic: Media(json['photoURL'], MediaType.Image),
      // json['followers'],
      // json['following'],
      // json['created'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alias': alias,
        'fullName': _fullName,
        'photoURL': profilePic.route,
        'created': created.toIso8601String(),
      };
}
