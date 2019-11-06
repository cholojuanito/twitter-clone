import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/base_vm.dart';

class CreateTweetVM extends BaseVM {
  Api _api;
  String _authorId;

  CreateTweetVM(this._authorId, this._api);

  Future<Tweet> create(String message,
      {String mediaPath, MediaType type = MediaType.Image}) async {
    var linkableItems = _parseMessage(message);
    List<Hashtag> hashtags = linkableItems['h'];
    List<Mention> mentions = linkableItems['m'];
    List<ExternalURL> urls = linkableItems['u'];

    Tweet _t = mediaPath == null
        ? Tweet(
            this._authorId,
            message,
            hashtags: hashtags,
            mentions: mentions,
            urls: urls,
          )
        : Tweet(
            this._authorId,
            message,
            hashtags: hashtags,
            mentions: mentions,
            urls: urls,
            media: Media(mediaPath, type),
          );

    Tweet resp = await _api.createTweet(_t);

    return resp;
  }

  Map<String, dynamic> _parseMessage(String message) {
    List<Hashtag> hashtags = [];
    List<Mention> mentions = [];
    List<ExternalURL> urls = [];

    if (Api.hashtagRegex.hasMatch(message)) {
      hashtags = _findHashtags(message);
    }
    if (Api.mentionRegex.hasMatch(message)) {
      mentions = _findMentions(message);
    }
    if (Api.urlRegex.hasMatch(message)) {
      urls = _findExternalUrls(message);
    }

    return {
      'h': hashtags,
      'm': mentions,
      'u': urls,
    };
  }

  List<Hashtag> _findHashtags(String m) {
    List<Hashtag> _h = [];
    var matches = Api.hashtagRegex.allMatches(m).map((m) => m.group(0));
    for (var match in matches) {
      _h.add(Hashtag(hashtagRoute, match.substring(1)));
    }
    return _h;
  }

  List<Mention> _findMentions(String m) {
    List<Mention> _m = [];
    var matches = Api.mentionRegex.allMatches(m).map((m) => m.group(0));
    for (var match in matches) {
      _m.add(Mention(profileRoute, match.substring(1)));
    }
    return _m;
  }

  List<ExternalURL> _findExternalUrls(String m) {
    List<ExternalURL> _urls = [];
    var matches = Api.urlRegex.allMatches(m).map((m) => m.group(0));
    for (var match in matches) {
      _urls.add(ExternalURL(match));
    }
    return _urls;
  }
}
