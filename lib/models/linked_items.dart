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
}

class Hashtag extends LinkedItem {
  final String word;
  List<String> postIds; // Ids of the posts that this hashtag is used in

  Hashtag(String route, this.word, {this.postIds, String id})
      : super(route, id: id);
}

class Mention extends LinkedItem {
  String userId;

  Mention(String route, this.userId, {String id}) : super(route, id: id);
}

class Media extends LinkedItem {
  MediaType type;

  Media(String route, this.type, {String id}) : super(route, id: id);
}

enum MediaType { Image, Video }
