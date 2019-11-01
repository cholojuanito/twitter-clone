import 'dart:io';

import 'package:twitter_clone/dummy_data.dart';
import 'package:twitter_clone/models/following.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/tweet_collections.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:uuid/uuid.dart';

class AWSTwitterApi extends Api {
  AuthenticationService _authService;
  final String baseUrl =
      'https://ei0piiispg.execute-api.us-west-1.amazonaws.com/mock-stage';
  final String region = 'us-west-1';
  final String userEndpoint = '/user';
  final String followEndpoint = '/follow';
  final String tweetEndpoint = '/tweet';
  final String hashtagEndpoint = '/hashtag';
  final String followersEndpoint = '/followers';
  final String followingEndpoint = '/following';
  final String tweetsEndpoint = '/tweets';

  // static final AWSTwitterApi _awsApi = AWSTwitterApi._internal();
  // AWSTwitterApi._internal();

  // factory AWSTwitterApi.getInstance() {
  //   return _awsApi;
  // }

  AWSTwitterApi(this._authService);

  @override
  Future<User> createUser(User user) async {
    allUsers.add(user);
    userStories[user.id] = [];
    userFollowersMap[user.id] = [];
    userFollowingMap[user.id] = [];
    return user;
  }

  @override
  Future<bool> isUniqueAlias(String alias) async {
    var u = await getUserByAlias(alias);
    return u == null ? true : false;
  }

  @override
  Future<User> getUserById(String id) async {
    User user = allUsers.firstWhere((u) => u.id == id, orElse: () => null);
    if (user == null) return null;
    user.followers = _buildUsersFollowers(user);
    user.following = _buildUsersFollowing(user);
    user.story = Story(_buildUsersStory(user));
    user.feed = Feed(_buildUsersFeed(user));
    return user;
  }

  @override
  Future<User> getUserByAlias(String alias) async {
    User user =
        allUsers.firstWhere((u) => u.alias == alias, orElse: () => null);
    if (user == null) return null;
    user.followers = _buildUsersFollowers(user);
    user.following = _buildUsersFollowing(user);
    user.story = Story(_buildUsersStory(user));
    user.feed = Feed(_buildUsersFeed(user));
    return user;
  }

  @override
  Future<bool> updateUserProfilePic(User newUser, String newPath) async {
    User user =
        allUsers.firstWhere((u) => u.id == newUser.id, orElse: () => null);

    user.profilePic.route = newPath;

    return true;
  }

  @override
  Future<Tweet> createTweet(Tweet tweet) async {
    if (tweet.hashtags.length > 0) {
      for (var hashtag in tweet.hashtags) {
        var h = await getHashtag(hashtag.word);
        if (h == null) {
          await createHashtag(hashtag.word, tweet.id);
        } else {
          await addTweetToHashtag(hashtag.word, tweet.id);
        }
      }
    }
    if (tweet.mentions.length > 0) {
      List toRemove = [];
      for (int i = 0; i < tweet.mentions.length; i++) {
        var m = tweet.mentions[i];
        var u = await getUserByAlias(m.userId);
        if (u == null) {
          toRemove.add(i);
        }
      }
      for (var idx in toRemove) {
        tweet.mentions.removeAt(idx);
      }
    }
    allTweets.add(tweet);
    userStories[tweet.authorId].add(tweet);
    // Upload media
    return tweet;
  }

  @override
  Future<Tweet> getTweetById(String tweetId) async {
    return allTweets.firstWhere((t) => t.id == tweetId, orElse: () => null);
  }

  @override
  Future<Hashtag> createHashtag(String word, String firstTweetId) async {
    // TODO maybe throw in checking for duplicates here?
    Hashtag h = Hashtag(hashtagRoute, word, tweetIds: [firstTweetId]);
    allHashtags.add(h);
    hashtagTweets[h.word] = h.tweetIds;
    return h;
  }

  @override
  Future<bool> addTweetToHashtag(String word, String tweetId) async {
    Hashtag h = await getHashtag(word);
    hashtagTweets[h.word].add(tweetId);
    h.tweetIds = hashtagTweets[h.word];
    return true;
  }

  @override
  Future<bool> removeTweetFromHashtag(String wrod, String tweetId) async {
    return true;
  }

  @override
  Future<Hashtag> getHashtag(String word) async {
    return allHashtags.firstWhere((h) => h.word == word, orElse: () => null);
  }

  @override
  Future<bool> follow(String currUserId, String otherUserId) async {
    Following newFollow = Following(currUserId, otherUserId, id: Uuid().v4());
    allFollows.add(newFollow);
    userFollowersMap[otherUserId].add(newFollow);
    userFollowingMap[currUserId].add(newFollow);
    return true;
  }

  @override
  Future<bool> unfollow(String currUserId, String otherUserId) async {
    allFollows.removeWhere(
        (f) => f.followerId == currUserId && f.followeeId == otherUserId);
    userFollowersMap[otherUserId].removeWhere(
        (f) => f.followerId == currUserId && f.followeeId == otherUserId);
    userFollowingMap[currUserId].removeWhere(
        (f) => f.followerId == currUserId && f.followeeId == otherUserId);
    return true;
  }

  @override
  Future<List<Tweet>> getFeed(String userId,
      {String lastKey, int pageSize = 10}) async {
    User u = await getUserById(userId);
    List<Tweet> moreItems = List.from(u.feed.tweets.sublist(0, 5));
    // u.feed.tweets.addAll(moreItems);
    return moreItems;
  }

  @override
  Future<List<Tweet>> getStory(String userId,
      {String lastKey, int pageSize = 10}) async {
    User u = await getUserById(userId);
    List<Tweet> moreItems = List.from(u.story.tweets.sublist(0, 5));
    // u.story.tweets.addAll(moreItems);
    return moreItems;
  }

  @override
  Future<List<Tweet>> getTweetsByHashtag(String word,
      {String lastKey, int pageSize = 10}) async {
    Hashtag h = await getHashtag(word);
    List<String> ids = List.from(h.tweetIds.sublist(0, 3));
    List<Tweet> moreItems = [];

    for (var id in ids.sublist(0, 3)) {
      moreItems
          .add(allTweets.firstWhere((t) => t.id == id, orElse: () => null));
    }

    return moreItems;
  }

  @override
  Future<List<User>> getFollowers(String userId,
      {String lastKey, int pageSize = 10}) async {
    // TODO: implement getNextFollowers
    return null;
  }

  @override
  Future<List<User>> getFollowing(String userId,
      {String lastKey, int pageSize = 10}) async {
    // TODO: implement getNextFollowing
    return null;
  }

  Future<String> _uploadMedia(File media) async {}

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
    List<Following> list = userFollowersMap[u.id];
    return list != null ? list : [];
  }

  List<Following> _buildUsersFollowing(User u) {
    List<Following> list = userFollowingMap[u.id];
    return list != null ? list : [];
  }
}
