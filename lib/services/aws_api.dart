import 'dart:io';

import 'package:twitter/dummy_data.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/tweet_collections.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/util/router.dart';

class AWSTwitterApi extends Api {
  static final AWSTwitterApi _awsApi = AWSTwitterApi._internal();
  AWSTwitterApi._internal();

  factory AWSTwitterApi.getInstance() {
    return _awsApi;
  }

  @override
  Future<bool> createUser(User user) async {
    allUsers.add(user);
    return true;
  }

  @override
  Future<bool> isUniqueAlias(String alias) async {
    for (var user in allUsers) {
      if (user.alias == alias) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<User> getUserById(String id) async {
    User user = allUsers.firstWhere((u) => u.id == id);
    user.followers = _buildUsersFollowers(user);
    user.following = _buildUsersFollowing(user);
    user.story = Story(_buildUsersStory(user));
    user.feed = Feed(_buildUsersFeed(user));
    return user;
  }

  @override
  Future<User> getUserByAlias(String alias) async {
    User user = allUsers.firstWhere((u) => u.alias == alias);
    user.followers = _buildUsersFollowers(user);
    user.following = _buildUsersFollowing(user);
    user.story = Story(_buildUsersStory(user));
    user.feed = Feed(_buildUsersFeed(user));
    return user;
  }

  @override
  Future<User> updateUser(User newUser) async {
    User user = allUsers.firstWhere((u) => u.id == newUser.id);
    user.feed = Feed(_buildUsersFeed(user));
    user.story = Story(_buildUsersStory(user));

    return user;
  }

  @override
  Future<bool> createTweet(Tweet tweet) async {
    userStories[tweet.authorId].add(tweet);
    // if contains hashtags add tweet to those hashtags
    // Upload media
    return true;
  }

  Future _uploadMedia(File media) {}

  @override
  Future<Tweet> getTweetById(String tweetId) async {
    return allTweets.firstWhere((t) => t.id == tweetId);
  }

  @override
  Future<bool> createHashtag(String word, String firstTweetId) async {
    // TODO maybe throw in checking for duplicates here?
    Hashtag h = Hashtag(hashtagRoute, word, postIds: [firstTweetId]);
    allHashtags.add(h);
    return true;
  }

  @override
  Future<List<Tweet>> getTweetsByHashtag(String word) async {
    List<Tweet> _tweets = [];
    try {
      Hashtag h = await getHashtag(word);
      for (var id in h.postIds) {
        _tweets.add(await getTweetById(id));
      }
    } on StateError catch (e) {
      _tweets = null;
    }
    return _tweets;
  }

  @override
  Future<bool> addTweetToHashtag(String word, String tweetId) async {
    Hashtag h = await getHashtag(word);
    h.postIds.add(tweetId);
    return true;
  }

  @override
  Future<Hashtag> getHashtag(String word) async {
    return allHashtags.firstWhere((h) => h.word == word);
  }

  @override
  Future<bool> follow(String currUserId, String otherUserId) async {
    // TODO: implement follow
    return null;
  }

  @override
  Future<bool> unfollow(String currUserId, String otherUserId) async {
    // TODO: implement unfollow
    return null;
  }

  @override
  Future<List<Tweet>> getNextFeedTweets(String userId, int pageNum) async {
    User u = await getUserById(userId);
    List<Tweet> moreItems = List.from(u.feed.tweets.sublist(0, 5));
    // u.feed.tweets.addAll(moreItems);
    return moreItems;
  }

  @override
  Future<List<Tweet>> getNextStoryTweets(String userId, int pageNum) async {
    User u = await getUserById(userId);
    List<Tweet> moreItems = List.from(u.story.tweets.sublist(0, 5));
    // u.story.tweets.addAll(moreItems);
    return moreItems;
  }

  @override
  Future<List<User>> getNextFollowers(String userId, int pageNum) async {
    // TODO: implement getNextFollowers
    return null;
  }

  @override
  Future<List<User>> getNextFollowing(String userId, int pageNum) async {
    // TODO: implement getNextFollowing
    return null;
  }

  List<Tweet> _buildUsersStory(User u) {
    // var t = allTweets.where((t) => t.authorId == u.id).toList();
    var t = userStories[u.id];
    t.sort();
    return t.reversed.toList();
  }

  List<Tweet> _buildUsersFeed(User u) {
    List<Tweet> feed = [];
    for (int i = 0; i < u.following.length; i++) {
      var tweets = userStories[u.following[i].followeeId];
      // var tweets = allTweets
      //     .where((t) => t.authorId == u.following[i].followeeId)
      //     .toList();
      feed.addAll(tweets);
    }
    feed.sort();
    return feed.reversed.toList();
  }

  List<Following> _buildUsersFollowers(User u) {
    return userFollowersMap[u.id];
  }

  List<Following> _buildUsersFollowing(User u) {
    return userFollowingMap[u.id];
  }
}
