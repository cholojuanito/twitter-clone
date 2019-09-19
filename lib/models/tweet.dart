import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:uuid/uuid.dart';

class Tweet with ChangeNotifier implements Comparable<Tweet> {
  String id = Uuid().v4();
  String authorId;

  String _message;
  String get message => _message;
  set message(String m) {
    this._message = m;
    notifyListeners();
  }

  List<Hashtag> hashtags;
  List<Mention> mentions;
  List<ExternalURL> urls;
  Media media;
  DateTime created;

  Tweet(
    this.id,
    this.authorId,
    this._message, {
    this.hashtags,
    this.mentions,
    this.urls,
    this.media,
    this.created,
  }) {
    if (this.created == null) {
      this.created = DateTime.now();
    }
  }

  int compareTo(Tweet other) {
    return this.created.compareTo(other.created);
  }

  factory Tweet.fromJson(Map<String, dynamic> json, String id) => Tweet(
        id,
        json['authorId'] as String,
        json['message'] as String,
        hashtags: json['hashtags'],
        mentions: json['mentions'],
        urls: json['urls'],
        media: json['media'],
        created: DateTime.parse(json['created']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'message': _message,
        'hashtags': hashtags,
        'mentions': mentions,
        'urls': urls,
        'media': media.route,
        'created': created.toIso8601String()
      };
}
