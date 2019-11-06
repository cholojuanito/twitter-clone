import 'dart:core';

import 'package:uuid/uuid.dart';

/// LinkedItem is an abstract class
abstract class LinkedItem {
  String id = Uuid().v4();
  String route;

  LinkedItem(this.route, {this.id});
}

class ExternalURL extends LinkedItem {
  ExternalURL(String route, {String id}) : super(route, id: id);

  factory ExternalURL.fromJson(Map<String, dynamic> json) {
    return ExternalURL(json['route'] as String);
  }

  Map<String, dynamic> toJson() => {
        'route': route,
      };
}

class Hashtag extends LinkedItem {
  final String word;
  List<String> tweetIds; // Ids of the posts that this hashtag is used in

  Hashtag(String route, this.word, {this.tweetIds, String id})
      : super(route, id: id);

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      json['word'],
      json['word'],
      tweetIds: List<String>.from(json['tweetIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'tweetIds': tweetIds,
      };
}

class Mention extends LinkedItem {
  String alias;

  Mention(String route, this.alias, {String id}) : super(route, id: id);

  factory Mention.fromJson(Map<String, dynamic> json) {
    return Mention(json['route'] as String, json['alias'] as String);
  }

  Map<String, dynamic> toJson() => {
        'route': route,
        'alias': alias,
      };
}

class Media extends LinkedItem {
  MediaType type;

  Media(String route, this.type, {String id}) : super(route, id: id);

  factory Media.fromJson(Map<String, dynamic> json) {
    var _typeStr = json['type'];
    MediaType _type;
    if (_typeStr == 'image') {
      _type = MediaType.Image;
    } else {
      _type = MediaType.Video;
    }
    return Media(json['path'] as String, _type);
  }

  Map<String, dynamic> toJson() => {
        'path': route,
        'type': this.type == MediaType.Image ? 'image' : 'video',
        // 'created': created?.toIso8601String(),
      };
}

enum MediaType { Image, Video }
