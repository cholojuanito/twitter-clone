import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/following.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/tweet_collections.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/vms/base_vm.dart';

class ProfileVM extends BaseVM with ChangeNotifier {
  Api _api;
  User user;
  User loggedInUser;
  bool isHomeScreen;
  List<Following> followers = [];
  List<Following> following = [];
  List<User> followersUsers = [];
  List<User> followingUsers = [];
  Feed feed = Feed([]);
  Story story = Story([]);
  Map<String, User> tweetAuthors = {};
  Map<String, User> authors = {};

  ProfileVM(this.user, this.loggedInUser, this._api,
      {this.isHomeScreen = false});

  Future<void> getInitialFollowers() async {
    List<User> items = [];
    if (this.followersUsers.length <= 0) {
      items = await _api.getFollowers(user.id);
      // for (var u in items) {
      //   User author;
      //   if (authors[t.authorId] == null) {
      //     author = await _api.getUserById(t.authorId);
      //     authors[t.authorId] = author;
      //     if (author == null) {
      //       author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
      //     }
      //   } else {
      //     author = authors[t.authorId];
      //   }
      //   tweetAuthors[t.id] = author;
      // }
      // // Must be called last since it notifys listeners, although that may not be needed
      addMoreFollowers(items);
    }

    notifyListeners();
    return items;
  }

  Future<void> getInitialFollowing() async {
    List<User> items = [];
    if (this.followingUsers.length <= 0) {
      items = await _api.getFollowing(user.id);
      // for (var u in items) {
      //   User author;
      //   if (authors[t.authorId] == null) {
      //     author = await _api.getUserById(t.authorId);
      //     authors[t.authorId] = author;
      //     if (author == null) {
      //       author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
      //     }
      //   } else {
      //     author = authors[t.authorId];
      //   }
      //   tweetAuthors[t.id] = author;
      // }
      // // Must be called last since it notifys listeners, although that may not be needed
      addMoreFollowing(items);
    }

    notifyListeners();
    return items;
  }

  Future<void> getInitialFeed() async {
    List<Tweet> items = [];
    if (this.feed.tweets.length <= 0) {
      items = await _api.getFeed(user.id);
      for (var t in items) {
        User author;
        if (authors[t.authorId] == null) {
          author = await _api.getUserById(t.authorId);
          authors[t.authorId] = author;
          if (author == null) {
            author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
          }
        } else {
          author = authors[t.authorId];
        }
        tweetAuthors[t.id] = author;
      }

      addMoreToFeed(items);
    } else {
      print('Using feed cache');
      items = this.feed.tweets;
    }

    return items;
  }

  Future<void> getInitialStory() async {
    List<Tweet> items = [];
    if (this.story.tweets.length <= 0) {
      items = await _api.getStory(user.id);
      addMoreToStory(items);
    } else {
      print('Using story cache');
      items = this.story.tweets;
    }

    return items;
  }

  Future<void> getMoreFollowers() async {
    setLoadingState(true);
    List<User> items = [];
    if (this.followersUsers.length <= 0) {
      items = await _api.getFollowers(user.id);
      // for (var u in items) {
      //   User author;
      //   if (authors[t.authorId] == null) {
      //     author = await _api.getUserById(t.authorId);
      //     authors[t.authorId] = author;
      //     if (author == null) {
      //       author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
      //     }
      //   } else {
      //     author = authors[t.authorId];
      //   }
      //   tweetAuthors[t.id] = author;
      // }
      // // Must be called last since it notifys listeners, although that may not be needed
      addMoreFollowers(items);
      setLoadingState(false);
    }
  }

  Future<void> getMoreFollowing() async {
    setLoadingState(true);
    List<User> items = [];
    if (this.followingUsers.length <= 0) {
      items = await _api.getFollowing(user.id);
      // for (var u in items) {
      //   User author;
      //   if (authors[t.authorId] == null) {
      //     author = await _api.getUserById(t.authorId);
      //     authors[t.authorId] = author;
      //     if (author == null) {
      //       author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
      //     }
      //   } else {
      //     author = authors[t.authorId];
      //   }
      //   tweetAuthors[t.id] = author;
      // }
      // // Must be called last since it notifys listeners, although that may not be needed
      addMoreFollowing(items);
      setLoadingState(false);
    }
  }

  Future<void> getMoreFeed() async {
    setLoadingState(true);
    var items = await _api.getFeed(user.id, lastKey: feed.tweets.last?.id);
    for (var t in items) {
      User author;
      if (authors[t.authorId] == null) {
        author = await _api.getUserById(t.authorId);
        authors[t.authorId] = author;
        if (author == null) {
          author = User('UNKNOWN_ALIAS', 'UNKNOWN_NAME', id: t.authorId);
        }
      } else {
        author = authors[t.authorId];
      }
      tweetAuthors[t.id] = author;
    }
    addMoreToFeed(items);
    await Future.delayed(Duration(seconds: 2));
    setLoadingState(false);
    return items;
  }

  Future<void> getMoreStory() async {
    setLoadingState(true);
    List<Tweet> items =
        await _api.getStory(user.id, lastKey: story.tweets.last?.id);
    addMoreToStory(items);
    await Future.delayed(Duration(seconds: 2));
    setLoadingState(false);
    return items;
  }

  void addMoreFollowers(List<User> f) {
    this.followersUsers.addAll(f);
    notifyListeners();
  }

  void addMoreFollowing(List<User> f) {
    this.followingUsers.addAll(f);
    notifyListeners();
  }

  void addMoreToFeed(List<Tweet> tweets) {
    this.feed.addAll(tweets);
    this.feed.tweets.sort();
    notifyListeners();
  }

  void addMoreToStory(List<Tweet> tweets) {
    this.story.addAll(tweets);
    this.story.tweets.sort();
    notifyListeners();
  }

  Future<bool> changeProfilePic(String imagePath) async {
    setLoadingState(true);
    var result = await this._api.updateUserProfilePic(loggedInUser, imagePath);
    // Change profile pic in memory
    setLoadingState(false);
    return result != null ? true : false;
  }

  @override
  void setLoadingState(bool state) {
    super.setLoadingState(state);
    notifyListeners();
  }
}
