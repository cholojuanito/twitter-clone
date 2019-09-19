import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:twitter/models/tweet.dart';

/// A PostCollection is a sorted list of posts
/// The list is sorted by when the post was created.
/// I.e. newer posts are at the beginning of the list
abstract class TweetCollection with ChangeNotifier {
  List<Tweet> _tweets;
  UnmodifiableListView get tweets => UnmodifiableListView(_tweets);

  TweetCollection(this._tweets);

  /// Adds a post and ensures the list is still sorted
  void add(Tweet p) {
    this._tweets.add(p);
    this._tweets.sort((a, b) => a.compareTo(b));
    notifyListeners();
  }

  Tweet tweetAt(int idx) => this._tweets[idx];

  bool remove(Tweet p) {
    notifyListeners();
    return this._tweets.remove(p);
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

// For dummy data
List<Tweet> dummyDataTweets = [];
