import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/models/tweet.dart';

abstract class Api {
  static RegExp urlRegex = RegExp(
      r'(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?');
  static RegExp hashtagRegex = RegExp(r'(?:|^)#[A-Za-z0-9\-\.\_]+(?:|$)');
  static RegExp mentionRegex = RegExp(r'(?:|^)@[A-Za-z0-9\-\.\_]+(?:|$)');

  // User methods
  Future<bool> createUser(User user);
  Future<bool> isUniqueAlias(String alias);
  Future<User> getUserById(String id);
  Future<User> getUserByAlias(String alias);
  Future<User> updateUser(User newUser);

  // Tweet methods
  Future<bool> createTweet(Tweet tweet);
  Future<Tweet> getTweetById(String tweetId);
  Future<List<Tweet>> getNextFeedTweets(String userId, int pageNum);
  Future<List<Tweet>> getNextStoryTweets(String userId, int pageNum);

  // Hashtag methods
  Future<bool> createHashtag(String word, String firstTweetId);
  Future<Hashtag> getHashtag(String word);
  Future<bool> addTweetToHashtag(String word, String tweetId);
  Future<List<Tweet>> getTweetsByHashtag(String word);

  // Following methods
  Future<List<User>> getNextFollowers(String userId, int pageNum);
  Future<List<User>> getNextFollowing(String userId, int pageNum);
  Future<bool> follow(String currUserId, String otherUserId);
  Future<bool> unfollow(String currUserId, String otherUserId);
}
