import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:twitter/models/tweet.dart';
import 'package:twitter/models/user.dart';
import 'package:twitter/screens/create_tweet_screen.dart';
import 'package:twitter/screens/login_screen.dart';
import 'package:twitter/screens/profile_screen.dart';
import 'package:twitter/screens/signup_screen.dart';
import 'package:twitter/screens/tweet_screen.dart';
import 'package:twitter/services/api.dart';
import 'package:twitter/vms/create_tweet_vm.dart';
import 'package:twitter/vms/profile_vm.dart';
import 'package:twitter/vms/tweet_vm.dart';

const String initialRoute = '/';
const String signUpRoute = 'signup';
const String profileRoute = 'profile';
const String hashtagRoute = 'hashtag';
const String tweetRoute = 'tweet';
const String createTweetRoute = 'create';

final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case initialRoute:
      return MaterialPageRoute(builder: (_) => LoginScreen());
      break;

    case signUpRoute:
      return MaterialPageRoute(builder: (_) => SignUpScreen());
      break;

    case profileRoute:
      ProfileRouteArguments _args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<ProfileVM>(
            builder: (_) => ProfileVM(_args.user),
            child: ProfileScreen(),
          );
        },
      );
      break;

    case tweetRoute:
      TweetRouteArguments _args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          var _api = Provider.of<Api>(context);
          var _vm = TweetVM(_args.tweet, _api, enlargeText: true);
          return ChangeNotifierProvider<TweetVM>.value(
            value: _vm,
            child: _vm.tweet.media != null
                ? TweetScreen(
                    mediaPath: _vm.tweet.media.route,
                    type: _vm.tweet.media.type,
                  )
                : TweetScreen(),
          );
        },
      );
      break;

    case createTweetRoute:
      CreateTweetRouteArguments _args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          var _api = Provider.of<Api>(context);
          return Provider<CreateTweetVM>(
            builder: (_) => CreateTweetVM(_args.user.id, _api),
            child: CreateTweetScreen(),
          );
        },
      );
      break;

    case hashtagRoute:
      HashtagRouteArguments _args = settings.arguments;
      return MaterialPageRoute(builder: (context) {
        return Container(
          child: Center(
            child:
                Text('Tweets that contain the hashtag #${_args.hashtag.word}'),
          ),
        );
      });

    default:
      return MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        },
      );
  }
}

class ProfileRouteArguments {
  final User user;

  ProfileRouteArguments(this.user);
}

class CreateTweetRouteArguments {
  final User user;

  CreateTweetRouteArguments(this.user);
}

class HashtagRouteArguments {
  final Hashtag hashtag;

  HashtagRouteArguments(this.hashtag);
}

class TweetRouteArguments {
  final Tweet tweet;
  final User author;

  TweetRouteArguments(this.tweet, this.author);
}