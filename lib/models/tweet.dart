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

  factory Tweet.fromJson(Map<String, dynamic> json) {
    var _h = json['hashtags'];
    List<Hashtag> _hashtags = [];
    if (_h != null) {
      for (Map h in _h) {
        _hashtags.add(Hashtag.fromJson(h));
      }
    }
    var _m = json['mentions'];
    List<Mention> _mentions = [];
    if (_m != null) {
      for (Map m in _m) {
        _mentions.add(Mention.fromJson(m));
      }
    }

    var _u = json['urls'];
    List<ExternalURL> _urls = [];
    if (_u != null) {
      for (Map url in _u) {
        _urls.add(ExternalURL.fromJson(url));
      }
    }

    Media _media;
    if (json['media'] != null) {
      _media = Media.fromJson(json['media']);
    }

    return Tweet(
      json['authorId'] as String,
      json['message'] as String,
      id: json['id'],
      hashtags: _hashtags,
      mentions: _mentions,
      urls: _urls,
      media: _media,
      // created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'message': _message,
        'hashtags': hashtags,
        'mentions': mentions,
        'urls': urls,
        'media': media,
        'created': created?.toIso8601String()
      };
}
