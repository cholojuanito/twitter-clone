import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/services/authentication.dart';
import 'package:twitter/vms/base_vm.dart';

import '../dummy_data.dart';

abstract class ListViewVM<T> extends BaseVM {
  static const int ITEMS_PER_PAGE = 10;
  int currPageNum = 1;

  List<T> _items;
  UnmodifiableListView<T> get items => UnmodifiableListView(_items);

  ListViewVM(this._items);

  Future getMoreItems();

  Future refresh();
}

class TweetListVM extends ListViewVM<Tweet> with ChangeNotifier {
  Api api;
  AuthenticationService authService;
  String hashtag;
  TweetListType type;
  TweetListVM(List<Tweet> items, this.authService, this.api, this.type,
      {this.hashtag})
      : super(items);

  @override
  Future getMoreItems() async {
    setLoadingState(true);
    notifyListeners();

    List<Tweet> nextItems = [];
    if (type == TweetListType.feed) {
      nextItems = await api.getNextFeedTweets(
          authService.getCurrentUser().id, currPageNum);
    } else if (type == TweetListType.story) {
      nextItems = await api.getNextStoryTweets(
          authService.getCurrentUser().id, currPageNum);
    } else {
      nextItems = await api.getTweetsByHashtag(hashtag);
    }

    await Future.delayed(const Duration(seconds: 3));

    this._items.addAll(nextItems);

    setLoadingState(false);
    notifyListeners();
    return null;
  }

  @override
  Future refresh() async {
    setLoadingState(true);
    notifyListeners();

    // TODO implement the refresh feature
    // Reset the List

    await Future.delayed(const Duration(seconds: 1));
    setLoadingState(false);
    notifyListeners();

    return null;
  }
}

class FollowingListVM extends ListViewVM<Following> with ChangeNotifier {
  Api api;
  AuthenticationService authService;
  List<User> users;
  FollowListType _type; // Followers or Following list
  FollowingListVM(List<Following> items, this.authService, this.api, this._type)
      : super(items);

  Future initUsers() async {
    this.users = [];
    if (_type == FollowListType.followers) {
      for (Following f in this.items) {
        var u = await api.getUserById(f.followerId);
        this.users.add(u);
      }
    } else {
      for (Following f in this.items) {
        this.users.add(await api.getUserById(f.followeeId));
      }
    }

    return;
  }

  @override
  Future getMoreItems() async {
    setLoadingState(true);
    notifyListeners();

    // TODO implement
    // Add the new items to the List

    await Future.delayed(const Duration(seconds: 1));

    setLoadingState(false);
    notifyListeners();
    return null;
  }

  @override
  Future refresh() async {
    setLoadingState(true);
    notifyListeners();

    // TODO implement the refresh feature
    // Reset the List

    await Future.delayed(const Duration(seconds: 1));
    setLoadingState(false);
    notifyListeners();

    return null;
  }
}

enum TweetListType { feed, story, hashtag }
enum FollowListType { followers, following }
