import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/tweet_collections.dart';
import 'package:twitter_clone/models/following.dart';
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

  Media profilePic;
  void changeProfilePic(String path) {
    this.profilePic = Media(path, MediaType.Image);
    notifyListeners();
  }

  List<Following> followers;
  List<Following> following;
  Feed feed;
  Story story;
  DateTime created = DateTime.now();

  static const String defaultProfileURL = 'assets/images/default_profile.png';

  // TODO add a total num tweets member
  User(
    this.alias,
    this._fullName, {
    this.id,
    this.profilePic,
    this.followers = const [],
    this.following = const [],
    this.feed,
    this.story,
    this.created,
  }) {
    if (this.created == null) {
      this.created = DateTime.now();
    }
    if (this.profilePic == null) {
      this.profilePic = Media(defaultProfileURL, MediaType.Image);
    }
    if (this.feed == null) {
      this.feed = Feed([]);
    }
    if (this.story == null) {
      this.story = Story([]);
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    Media _media = Media.fromJson(json['profilePic']);

    return User(
      json['alias'] as String,
      json['name'] as String,
      id: json['id'] as String,
      profilePic: _media,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alias': alias,
        'name': _fullName,
        'profilePic': profilePic.toJson(),
        'created': created?.toIso8601String(),
      };
}
