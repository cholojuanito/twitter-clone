import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/tweet.dart';

/// A PostCollection is a sorted list of posts
/// The list is sorted by when the post was created.
/// I.e. newer posts are at the beginning of the list
abstract class TweetCollection with ChangeNotifier {
  List<Tweet> tweets = [];

  TweetCollection(this.tweets);

  /// Adds a post and ensures the list is still sorted
  void add(Tweet p) {
    this.tweets.add(p);
    this.tweets.sort((a, b) => a.compareTo(b));
    notifyListeners();
  }

  Tweet tweetAt(int idx) => this.tweets[idx];

  bool remove(Tweet p) {
    notifyListeners();
    return this.tweets.remove(p);
  }

  // void clear();
}

class Story extends TweetCollection {
  Story(List<Tweet> tweets) : super(tweets);
}

class Feed extends TweetCollection {
  String userId; //The id of the user this feed belongs to

  Feed(List<Tweet> tweets, {this.userId}) : super(tweets);
}
