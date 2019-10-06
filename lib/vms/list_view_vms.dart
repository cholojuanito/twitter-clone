import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
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
  String currUserId;
  String hashtag;
  TweetListType type;
  TweetListVM(List<Tweet> items, this.currUserId, this.api, this.type,
      {this.hashtag})
      : super(items);

  @override
  Future getMoreItems() async {
    setLoadingState(true);
    notifyListeners();

    List<Tweet> nextItems = [];
    if (type == TweetListType.feed) {
      nextItems = await api.getNextFeedTweets(currUserId, currPageNum);
    } else if (type == TweetListType.story) {
      nextItems = await api.getNextStoryTweets(currUserId, currPageNum);
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
  List<User> users;
  bool _getFollowers; // Followers or Following list
  FollowingListVM(List<Following> items, this._getFollowers) : super(items) {
    this.users = _getUsersFromList();
  }

  List<User> _getUsersFromList() {
    List<User> _u = [];
    if (_getFollowers) {
      for (Following f in this.items) {
        _u.add(allUsers.firstWhere((u) => u.id == f.followerId));
      }
    } else {
      for (Following f in this.items) {
        _u.add(allUsers.firstWhere((u) => u.id == f.followeeId));
      }
    }

    return _u;
  }

  @override
  Future<void> getMoreItems() async {
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
  Future<void> refresh() async {
    setLoadingState(true);
    notifyListeners();

    // TODO implement the refresh feature
    // Reset the List

    await Future.delayed(const Duration(seconds: 1));
    setLoadingState(false);
    notifyListeners();

    return null;
  }

  @override
  Future onListItemCreate(int idx) {
    // TODO: implement onListItemCreate
    return null;
  }
}

enum TweetListType { feed, story, hashtag }
