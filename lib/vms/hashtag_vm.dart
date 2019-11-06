import 'package:flutter/cupertino.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/vms/base_vm.dart';

class HashtagVM extends BaseVM with ChangeNotifier {
  String word;
  List<Tweet> tweets = [];
  Map<String, User> tweetAuthors = {};
  Map<String, User> authors = {};
  Api api;

  HashtagVM(this.word, this.api);

  Future<void> getInitialTweets() async {
    List<Tweet> items = [];
    if (this.tweets.length <= 0) {
      items = await api.getTweetsByHashtag(this.word);
      for (var t in items) {
        User author;
        if (authors[t.authorId] == null) {
          author = await api.getUserById(t.authorId);
          authors[t.authorId] = author;
          if (author == null) {
            author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
          }
        } else {
          author = authors[t.authorId];
        }
        tweetAuthors[t.id] = author;
      }
      addMoreTweets(items);
    } else {
      print('Using the cache first');
      items = this.tweets;
    }

    notifyListeners();
    return items;
  }

  Future<void> getMoreTweets() async {
    setLoadingState(true);
    List<Tweet> items =
        await api.getTweetsByHashtag(this.word, lastKey: this.tweets.last?.id);
    for (var t in items) {
      User author;
      if (authors[t.authorId] == null) {
        author = await api.getUserById(t.authorId);
        authors[t.authorId] = author;
        if (author == null) {
          author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
        }
      } else {
        author = authors[t.authorId];
      }
      tweetAuthors[t.id] = author;
    }

    addMoreTweets(items);
    await Future.delayed(Duration(seconds: 2));
    setLoadingState(false);
    return items;
  }

  void addMoreTweets(List<Tweet> t) {
    this.tweets.addAll(t);
  }
}
