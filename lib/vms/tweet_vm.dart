import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/base_vm.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:url_launcher/url_launcher.dart';

class TweetVM extends BaseVM with ChangeNotifier {
  static const String ALIAS_PREFIX = '@';
  static const String HASHTAG_PREFIX = '#';
  Api _api;
  Tweet tweet;
  User author;
  Text linkedMessage;
  List<GestureRecognizer> _recognizers;
  bool enlargeText;

  double _largeLinkTextSize = 28.0;
  double _smallLinkTextSize = 18.0;
  double _largeTextSize = 26.0;
  double _smallTextSize = 16.0;

  TextStyle _linkStyle;
  TextStyle _normalStyle;

  TweetVM(this.tweet, this.author, this._api, {this.enlargeText = false}) {
    this._recognizers = [];
    this._linkStyle = TextStyle(
      color: Colors.blue,
      fontSize: this.enlargeText ? _largeLinkTextSize : _smallLinkTextSize,
    );

    this._normalStyle = TextStyle(
      color: Colors.black,
      fontSize: this.enlargeText ? _largeTextSize : _smallTextSize,
    );

    // This needs to go last
    this.linkedMessage = _createMessageWidget();
  }

  @override
  void dispose() {
    _recognizers?.forEach((r) => r?.dispose());
    super.dispose();
  }

// find out if checking each hashtag or this method works best
  Text _createMessageWidget() {
    List<TextSpan> span = [];
    List<String> words = this.tweet.message.split(' ');
    words.forEach((w) {
      if (w.length > 1) {
        var _trimmed = w.trim();
        if (this._isHashtag(_trimmed)) {
          GestureRecognizer _r = TapGestureRecognizer()
            ..onTap = () {
              Future<Hashtag> future =
                  this._api.getHashtag(_trimmed.substring(1));
              future.then((h) {
                appNavKey.currentState.pushNamed(hashtagRoute,
                    arguments: HashtagRouteArguments(h));
              }).catchError(
                (e) => print('Error when routing to hashtag! $e'),
              );
            };

          _recognizers.add(_r);
          span.add(
            TextSpan(
              text: '$w ',
              style: _linkStyle,
              recognizer: _r,
            ),
          );
        } else if (this._isMention(_trimmed)) {
          GestureRecognizer _r = TapGestureRecognizer()
            ..onTap = () {
              Future<User> future =
                  this._api.getUserByAlias(_trimmed.substring(1));
              future.then((u) {
                appNavKey.currentState.pushNamed(profileRoute,
                    arguments: ProfileRouteArguments(u));
              }).catchError(
                (e) => print('Error when routing to profile! $e'),
              );
            };

          _recognizers.add(_r);
          span.add(
            TextSpan(
              text: '$w ',
              style: _linkStyle,
              recognizer: _r,
            ),
          );
        } else if (this._isUrl(_trimmed)) {
          String url;
          if (_trimmed.contains(Api.beginUrlRegex)) {
            url = Uri.encodeFull(_trimmed).toString();
          } else {
            url = Uri.encodeFull('http://' + _trimmed).toString();
          }
          GestureRecognizer _r = TapGestureRecognizer()
            ..onTap = () {
              canLaunch(url).then((val) {
                if (val) {
                  launch(url);
                } else {
                  // launch(url);
                }
              });
            };

          _recognizers.add(_r);
          span.add(
            TextSpan(
              text: '$w ',
              style: _linkStyle,
              recognizer: _r,
            ),
          );
        } else {
          span.add(
            TextSpan(
              text: '$w ',
              style: _normalStyle,
            ),
          );
        }
      } else {
        span.add(
          TextSpan(
            text: '$w ',
            style: _normalStyle,
          ),
        );
      }
    });

    return Text.rich(
      TextSpan(
        children: span,
      ),
    );
  }

  bool _isHashtag(String word) {
    if (word.startsWith(HASHTAG_PREFIX)) {
      for (var h in this.tweet.hashtags) {
        if (h.word == word.substring(1)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isMention(String word) {
    if (word.startsWith(ALIAS_PREFIX)) {
      for (var m in this.tweet.mentions) {
        if (m.alias == word.substring(1)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isUrl(String word) {
    return Api.urlRegex.hasMatch(word);
  }
}
