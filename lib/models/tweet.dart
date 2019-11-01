import 'dart:core';

import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/linked_items.dart';
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

  String getCreatedRelativeTime() =>
      timeago.format(this.created, locale: 'en_short');

  Tweet(
    this.authorId,
    this._message, {
    this.id,
    this.hashtags = const [],
    this.mentions = const [],
    this.urls = const [],
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

  factory Tweet.fromJson(Map<String, dynamic> json) => Tweet(
        json['authorId'] as String,
        json['message'] as String,
        id: json['id'],
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
