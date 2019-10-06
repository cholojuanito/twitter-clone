import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/following.dart';
import 'package:twitter/util/router.dart';

List<User> allUsers;
List<Tweet> allTweets;
List<Following> allFollows;
List<Hashtag> allHashtags;
Map<String, List<Tweet>> userStories = {};
Map<String, List<Following>> userFollowersMap = {};
Map<String, List<Following>> userFollowingMap = {};
Map<String, List<String>> hashtagTweets = {};

const String mentionRoute = 'profile';

User u1 = User('id1', 'number1', 'Tanner Davis');
User u2 = User('id2', 'dos-dos', 'Sr. Dos');
User u3 = User('id3', 'tres', 'Numba three!');

// Hashtags
Hashtag h1 = Hashtag(hashtagRoute, 'hashtag');
Hashtag h2 = Hashtag(hashtagRoute, 'nashtag');
Hashtag h3 = Hashtag(hashtagRoute, 'federer');
Hashtag h4 = Hashtag(hashtagRoute, 'something');
Hashtag h5 = Hashtag(hashtagRoute, 'newtag');
Hashtag h6 = Hashtag(hashtagRoute, 'one');
Hashtag h7 = Hashtag(hashtagRoute, 'number1');

// Tweets
Tweet t11 = Tweet('t1', u1.id, 'Some tweet by me!');
Tweet t12 = Tweet('t2', u1.id,
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.');
Tweet t13 = Tweet('t3', u1.id, 'This is my 3rd tweet');
Tweet t21 = Tweet('t4', u2.id, 'This is my first tweet');
Tweet t22 = Tweet('t5', u2.id, 'I am tweeting!');

Tweet t31 = Tweet(
  't6',
  u3.id,
  'Listen to me @dos-dos and @number1',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
);
Tweet t32 = Tweet(
  't7',
  u3.id,
  'Let\s test a hashtag #hashtag #nashtag with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h2,
  ],
);
Tweet t33 = Tweet(
  't8',
  u3.id,
  'Let\s test a hashtag #hashtag #nashtag with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h2,
  ],
);
Tweet t34 = Tweet(
  't9',
  u3.id,
  'Let\s test a hashtag #hashtag #something with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h4,
  ],
);
Tweet t35 = Tweet(
  't10',
  u3.id,
  'Let\s test a hashtag #nashtag #newtag with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h5,
  ],
);
Tweet t36 = Tweet(
  't11',
  u3.id,
  'Let\s test a hashtag #hashtag #nashtag with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h2,
  ],
);
Tweet t37 = Tweet(
  't12',
  u3.id,
  'Let\s test a hashtag #federer #nashtag with some mentions like @dos-dos or @number1 or maybe test some weird stuff like just the @ symbol. This needs to be pretty long because, yea. now for a url www.google.com and https://slack.com or http://www.flutter.dev',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h1,
    h2,
  ],
);
// For adding each round of pagination
Tweet t38 = Tweet(
  't13',
  u3.id,
  'Listen to me @dos-dos and @number1. I\'ve got some new hashtags #one',
  mentions: [
    Mention(mentionRoute, u1.alias),
    Mention(mentionRoute, u2.alias),
  ],
  hashtags: [
    h6,
  ],
);
Tweet t39 = Tweet(
  't14',
  u3.id,
  'Testing mention vs hashtag with same word @number1. #number1',
  mentions: [
    Mention(mentionRoute, u1.alias),
  ],
  hashtags: [
    h7,
  ],
);
// Tweet t310 = Tweet(
//   't15',
//   u3.id,
//   'Listen to me @dos-dos and @number1',
//   mentions: [
//     Mention(mentionRoute, u1.alias),
//     Mention(mentionRoute, u2.alias),
//   ],
// );
// Tweet t311 = Tweet(
//   't116',
//   u3.id,
//   'Listen to me @dos-dos and @number1 this should be the last one',
//   mentions: [
//     Mention(mentionRoute, u1.alias),
//     Mention(mentionRoute, u2.alias),
//   ],
// );
// Tweet t312 = Tweet(
//   't116',
//   u3.id,
//   'Listen to me @dos-dos and @number1, hi.',
//   mentions: [
//     Mention(mentionRoute, u1.alias),
//     Mention(mentionRoute, u2.alias),
//   ],
// );
// Tweet t313 = Tweet(
//   't13',
//   u3.id,
//   'Yo @dos-dos and @number1. I\'ve got some new hashtags #one',
//   mentions: [
//     Mention(mentionRoute, u1.alias),
//     Mention(mentionRoute, u2.alias),
//   ],
//   hashtags: [
//     h6,
//   ],
// );

Following u1tou2 = Following('f1', u1.id, u2.id);
Following u1tou3 = Following('f2', u1.id, u3.id);
Following u2tou1 = Following('f3', u2.id, u1.id);
Following u3tou2 = Following('f4', u3.id, u2.id);

initDummyData() {
  allTweets = [
    t11,
    t12,
    t13,
    t21,
    t22,
    t31,
    t32,
    t33,
    t34,
    t35,
    t36,
    t37,
    t38,
    t39,
  ];

  allFollows = [u1tou2, u1tou3, u2tou1, u3tou2];

  allHashtags = [h1, h2, h3, h4, h5, h6, h7];

  allUsers = [u1, u2, u3];

  for (var u in allUsers) {
    userStories[u.id] = _buildUsersStory(u);
    userFollowersMap[u.id] =
        allFollows.where((f) => f.followeeId == u.id).toList();
    userFollowingMap[u.id] =
        allFollows.where((f) => f.followerId == u.id).toList();
  }

  for (var h in allHashtags) {
    h.tweetIds = allTweets
        .where((t) => t.message.contains('#${h.word}'))
        .map((t) => t.id)
        .toList();

    hashtagTweets[h.word] = h.tweetIds;
  }
}

List<Tweet> _buildUsersStory(User u) {
  var t = allTweets.where((t) => t.authorId == u.id).toList();
  t.sort();
  return t.reversed.toList();
}
