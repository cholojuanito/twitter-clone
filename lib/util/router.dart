import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/screens/create_tweet_screen.dart';
import 'package:twitter_clone/screens/hashtag_screen.dart';
import 'package:twitter_clone/screens/login_screen.dart';
import 'package:twitter_clone/screens/profile_screen.dart';
import 'package:twitter_clone/screens/signup_screen.dart';
import 'package:twitter_clone/screens/tweet_screen.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/vms/create_tweet_vm.dart';
import 'package:twitter_clone/vms/hashtag_vm.dart';
import 'package:twitter_clone/vms/profile_vm.dart';
import 'package:twitter_clone/vms/tweet_vm.dart';

const String initialRoute = '/';
const String homeRoute = 'home';
const String signUpRoute = 'signup';
const String profileRoute = 'profile';
const String hashtagRoute = 'hashtag';
const String tweetRoute = 'tweet';
const String createTweetRoute = 'create';

final GlobalKey<NavigatorState> appNavKey = GlobalKey<NavigatorState>();

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case initialRoute:
      return MaterialPageRoute(
        builder: (context) {
          var _auth = Provider.of<AuthenticationService>(context);
          return LoginScreen(_auth);
        },
      );
      break;

    case homeRoute:
      return MaterialPageRoute(
        builder: (context) {
          var _api = Provider.of<Api>(context);
          var _auth = Provider.of<AuthenticationService>(context);
          return ChangeNotifierProvider<ProfileVM>(
            builder: (_) => ProfileVM(
              _auth.getCurrentUserSync(),
              _auth.getCurrentUserSync(),
              _api,
              isHomeScreen: true,
            ),
            child: ProfileScreen(),
          );
        },
      );
      break;

    case signUpRoute:
      return MaterialPageRoute(builder: (_) => SignUpScreen());
      break;

    case profileRoute:
      ProfileRouteArguments _args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          var _api = Provider.of<Api>(context);
          var _auth = Provider.of<AuthenticationService>(context);
          return ChangeNotifierProvider<ProfileVM>(
            builder: (_) =>
                ProfileVM(_args.user, _auth.getCurrentUserSync(), _api),
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
          var _auth = Provider.of<AuthenticationService>(context);
          var _vm = TweetVM(_args.tweet, _args.author, _api, enlargeText: true);
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
      return MaterialPageRoute<Tweet>(
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
      return MaterialPageRoute(
        builder: (context) {
          var _api = Provider.of<Api>(context);
          var _vm = HashtagVM(_args.hashtag.word, _api);
          return ChangeNotifierProvider<HashtagVM>.value(
            value: _vm,
            child: HashtagScreen(),
          );
        },
      );

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
