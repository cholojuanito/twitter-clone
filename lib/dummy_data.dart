import 'package:twitter/models/user.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/tweet_collections.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/following.dart';

User u1 = User('id1', '@number1', 'Tanner Davis');
User u2 = User('id2', '@dos-dos', 'Sr. Dos');
User u3 = User('id3', '@tres', 'Numba three!');

Tweet t11 = Tweet('t1', u1.id, 'Some tweet by me!');
Tweet t12 = Tweet('t2', u1.id,
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.');
Tweet t13 = Tweet('t3', u1.id, 'This is my 3rd tweet');
Tweet t21 = Tweet('t4', u2.id, 'This is my first tweet');
Tweet t22 = Tweet('t5', u2.id, 'I am tweeting!');
Tweet t31 = Tweet('t6', u3.id, 'Listen to me @dos-dos and @number1');
Tweet t32 = Tweet('t7', u3.id, 'Let\s test a hashtag #hashtag #nashtag');

Following u1tou2 = Following('f1', u1.id, u2.id);
Following u1tou3 = Following('f2', u1.id, u3.id);
Following u2tou1 = Following('f3', u2.id, u1.id);
Following u3tou2 = Following('f4', u3.id, u2.id);

initDummyData() {
  List<Tweet> allTweets = [t11, t12, t13, t21, t22, t31, t32];
  List<Following> allFollows = [u1tou2, u1tou3, u2tou1, u3tou2];
  u1.followers = allFollows.where((f) => f.followeeId == u1.id).toList();
  u1.following = allFollows.where((f) => f.followerId == u1.id).toList();

  u2.followers = allFollows.where((f) => f.followeeId == u2.id).toList();
  u2.following = allFollows.where((f) => f.followerId == u2.id).toList();

  u3.followers = allFollows.where((f) => f.followeeId == u3.id).toList();
  u3.following = allFollows.where((f) => f.followerId == u3.id).toList();

  List<Tweet> u1Feed = _buildUsersFeed(u1, allTweets);
  List<Tweet> u1Story = _buildUsersStory(u1, allTweets);
  u1.feed = Feed(u1Feed, userId: u1.id);
  u1.story = Story(u1Story);

  List<Tweet> u2Feed = _buildUsersFeed(u2, allTweets);
  List<Tweet> u2Story = _buildUsersStory(u2, allTweets);
  u2.feed = Feed(u2Feed, userId: u2.id);
  u2.story = Story(u2Story);

  List<Tweet> u3Feed = _buildUsersFeed(u3, allTweets);
  List<Tweet> u3Story = _buildUsersStory(u3, allTweets);
  u3.feed = Feed(u3Feed, userId: u3.id);
  u3.story = Story(u3Story);
}

List<Tweet> _buildUsersStory(User u, List<Tweet> allTweets) {
  return allTweets.where((t) => t.authorId == u1.id).toList();
}

List<Tweet> _buildUsersFeed(User u, List<Tweet> allTweets) {
  List<Tweet> feed = [];
  for (int i = 0; i < u.following.length; i++) {
    feed.addAll(
        allTweets.where((t) => t.authorId == u.following[i].followeeId));
  }
  return feed;
}
