import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/models/tweet.dart';

abstract class Api {
  static final RegExp wordSplitRegex = RegExp(r'(?=[?.!,]+)|(?=\s+)');
  static final RegExp urlRegex = RegExp(
      r'(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?');
  static final RegExp hashtagRegex = RegExp(r'(?:|^)#[A-Za-z0-9\-\.\_]+(?:|$)');
  static final RegExp mentionRegex = RegExp(r'(?:|^)@[A-Za-z0-9\-\.\_]+(?:|$)');

  // User methods
  Future<User> createUser(User user);
  Future<bool> isUniqueAlias(String alias);
  Future<User> getUserById(String id);
  Future<User> getUserByAlias(
      String id); // TODO figure out what to do with this
  Future<bool> updateUserProfilePic(User newUser, String newPath);

  // Tweet methods
  Future<Tweet> createTweet(Tweet tweet);
  Future<Tweet> getTweetById(String tweetId);

  // Hashtag methods
  Future<Hashtag> createHashtag(String word, String firstTweetId);
  Future<Hashtag> getHashtag(String word);
  Future<bool> addTweetToHashtag(String word, String tweetId);
  Future<bool> removeTweetFromHashtag(String word, String tweetId);

  // Following methods
  Future<bool> follow(String currUserId, String otherUserId);
  Future<bool> unfollow(String currUserId, String otherUserId);

  // Collection methods
  Future<List<User>> getFollowers(String userId,
      {String lastKey, int pageSize});
  Future<List<User>> getFollowing(String userId,
      {String lastKey, int pageSize});
  Future<List<Tweet>> getTweetsByHashtag(String word,
      {String lastKey, int pageSize});
  Future<List<Tweet>> getFeed(String userId, {String lastKey, int pageSize});
  Future<List<Tweet>> getStory(String userId, {String lastKey, int pageSize});
}
