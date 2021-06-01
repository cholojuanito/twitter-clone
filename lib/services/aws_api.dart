import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:mime/mime.dart';
import 'package:twitter_clone/models/following.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/tweet_collections.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AWSTwitterApi implements Api {
  AuthenticationService _authService; //TODO remove
  http.Client _client;
  final String baseUrl = 'ei0piiispg.execute-api.us-west-1.amazonaws.com';
  final String apiVersion = '/v1';
  final String region = 'us-west-1';
  final String userEndpoint = '/user';
  final String followEndpoint = '/follow';
  final String tweetEndpoint = '/tweet';
  final String hashtagEndpoint = '/hashtag';
  final String followersEndpoint = '/followers';
  final String followingEndpoint = '/following';
  final String storyEndpoint = '/tweets/story';
  final String feedEndpoint = '/tweets/feed';
  final String hashtagTweetsEndpoint = '/tweets/hashtag';
  final String mediaEndpoint = '/media';
  final Map<String, String> _baseHeaders = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  AWSTwitterApi(this._authService) {
    _client = http.Client();
  }

  @override
  Future<User> createUser(User user) async {
    var endpoint = apiVersion + userEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);

    if (user.profilePic.route != User.defaultProfileURL) {
      File f = File(user.profilePic.route);
      String url = await _uploadMedia(f, user.id);
      if (url != null) {
        user.profilePic = new Media(url, MediaType.Image);
      } else {
        throw Exception('Couldn\'t upload media, try again');
      }
    }

    var params = user.toJson();
    var resp = await _client.post(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    User u;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        u = User.fromJson(body['data']);
        print('Success calling createUser');
        break;
      default:
        print('Error calling createUser. Code: ${resp.statusCode}');
    }

    return u;
  }

  @override
  Future<bool> isUniqueAlias(String alias) async {
    var u = await getUserByAlias(alias);
    return u == null ? true : false;
  }

  @override
  Future<User> getUserById(String id) async {
    var endpoint = apiVersion + userEndpoint + '/id/$id';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);
    User user;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        user = User.fromJson(body['data']);
        print('Success calling getUserById');
        break;

      default:
        print('Error calling getUserById. Code: ${resp.statusCode}');
    }

    return user;
  }

  @override
  Future<User> getUserByAlias(String alias) async {
    var endpoint = apiVersion + userEndpoint + '/$alias';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);
    User user;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        user = User.fromJson(body['data']);
        print('Success calling getUserByAlias');
        break;
      case HttpStatus.internalServerError:
      case HttpStatus.notImplemented:
      case HttpStatus.badGateway:
      case HttpStatus.serviceUnavailable:
      case HttpStatus.gatewayTimeout:
      case HttpStatus.httpVersionNotSupported:
        print('500 error calling getUserByAlias. Code: ${resp.statusCode}');
        break;
      case HttpStatus.badRequest:
      case HttpStatus.unauthorized:
      case HttpStatus.forbidden:
      case HttpStatus.notFound:
        print('400 error calling getUserByAlias. Code: ${resp.statusCode}');

        break;
      default:
        print('Error calling getUserByAlias. Code: ${resp.statusCode}');
    }

    return user;
  }

  @override
  Future<User> updateUserProfilePic(User user, String newPath) async {
    var endpoint = apiVersion + userEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);

    File f;
    try {
      f = File(newPath);
    } catch (err) {
      print('Unable to find file');
      return null;
    }

    String newMediaUrl = await _uploadMedia(f, user.id);

    Map params = {
      'id': user.id,
      'action': 'replace',
      'value': {
        'profilePicPath': newMediaUrl,
        // 'name':
      },
    };
    var resp = await _client.patch(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    User u;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        u = User.fromJson(body['data']);
        print('Success calling updateUser');
        break;
      default:
        print('Error calling updateUser. Code: ${resp.statusCode}');
    }

    return u != null ? u : user;
  }

  @override
  Future<Tweet> createTweet(Tweet tweet) async {
    var endpoint = apiVersion + tweetEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);

    if (tweet?.media != null) {
      File f = File(tweet.media.route);
      String url = await _uploadMedia(f, tweet.authorId);
      if (url != null) {
        var oldMediaType = tweet.media.type;
        tweet.media = new Media(url, oldMediaType);
      } else {
        throw Exception('Couldn\'t upload media, try again');
      }
    }

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
        var u = await getUserByAlias(m.alias);
        if (u == null) {
          toRemove.add(i);
        }
      }
      for (var idx in toRemove) {
        tweet.mentions.removeAt(idx);
      }
    }

    var params = tweet.toJson();
    var resp = await _client.post(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    Tweet t;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        t = Tweet.fromJson(body['data']);
        print('Success calling createTweet');
        break;
      default:
        print('Error calling createTweet. Code: ${resp.statusCode}');
    }

    return tweet; //TODO change to 't'
  }

  @override
  Future<Tweet> getTweetById(String tweetId) async {
    var endpoint = apiVersion + tweetEndpoint + '/id/$tweetId';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);

    Tweet t;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        t = Tweet.fromJson(body['data']);
        print('Success calling createTweet');
        break;
      default:
        print('Error calling createTweet. Code: ${resp.statusCode}');
    }

    return t;
  }

  @override
  Future<Hashtag> createHashtag(String word, String firstTweetId) async {
    var endpoint = apiVersion + hashtagEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);

    Map params = {
      'word': word,
      'tweetId': firstTweetId,
    };
    var resp = await _client.post(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    Hashtag h;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        h = Hashtag.fromJson(body['data']);
        print('Success calling createHashtag');
        break;
      default:
        print('Error calling createHashtag. Code: ${resp.statusCode}');
    }

    return h;
  }

  @override
  Future<bool> addTweetToHashtag(String word, String tweetId) async {
    var endpoint = apiVersion + hashtagEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);
    Map params = {
      'word': word,
      'action': 'add',
      'value': {
        'tweetId': tweetId,
      },
    };

    var resp = await this._client.patch(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    Hashtag hashtag;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        hashtag = Hashtag.fromJson(body['data']);
        print('Success calling getHashtag');
        break;
      default:
        print('Error calling getHashtag. Code: ${resp.statusCode}');
    }

    return hashtag != null ? true : false;
  }

  @override
  Future<bool> removeTweetFromHashtag(String wrod, String tweetId) async {
    return true;
  }

  @override
  Future<Hashtag> getHashtag(String word) async {
    var endpoint = apiVersion + hashtagEndpoint + '/id/$word';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);

    Hashtag hashtag;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        hashtag = Hashtag.fromJson(body['data']);
        print('Success calling getHashtag');
        break;
      default:
        print('Error calling getHashtag. Code: ${resp.statusCode}');
    }

    return hashtag;
  }

  @override
  Future<Following> getFollowById(String id) async {
    var endpoint = apiVersion + followEndpoint + '/id/$id';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);

    switch (resp.statusCode) {
      case HttpStatus.ok:
        Following followTest = Following.fromJson(body['data']);
        print('Success calling getFollowById');
        break;
      default:
        print('Error calling getFollowById. Code: ${resp.statusCode}');
    }
  }

  @override
  Future<Following> getFollowByUserIds(
      String followerId, String followeeId) async {
    var endpoint = apiVersion + followEndpoint + '/$followerId/$followeeId';
    Uri url = Uri.https(baseUrl, endpoint);

    var resp = await _client.get(url);
    var body = jsonDecode(resp.body);

    switch (resp.statusCode) {
      case HttpStatus.ok:
        Following followTest = Following.fromJson(body['data']);
        print('Success calling getFollowByUserIds');
        break;
      default:
        print('Error calling getFollowByUserIds. Code: ${resp.statusCode}');
    }
  }

  @override
  Future<Following> createFollow(Following follow) async {
    var endpoint = apiVersion + followEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);

    Map params = follow.toJson();
    var resp = await _client.post(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    Following f;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        f = Following.fromJson(body['data']);
        print('Success calling follow');
        break;
      default:
        print('Error calling follow. Code: ${resp.statusCode}');
    }
    return f != null ? f : null;
  }

  @override
  Future<Following> updateFollow(Following follow, String action) async {
    var endpoint = apiVersion +
        followEndpoint +
        '/${follow.followerId}/${follow.followeeId}';
    Uri url = Uri.https(baseUrl, endpoint);

    Map params = {
      'id': follow.id,
      'action': action,
      'value': {
        'active': action == 'follow' ? true : false,
      },
    };
    var resp = await _client.patch(url, body: jsonEncode(params));
    var body = jsonDecode(resp.body);

    Following f;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        f = Following.fromJson(body['data']);
        print('Success calling updateFollow');
        break;
      default:
        print('Error calling updateFollow. Code: ${resp.statusCode}');
    }

    follow.isActive = action == 'follow';
    return follow;
  }

  @override
  Future<List<Tweet>> getFeed(String userId,
      {String lastKey, int pageSize = 10}) async {
    var endpoint = apiVersion + feedEndpoint + '/$userId';
    Map<String, String> query = {
      'lastKey': lastKey,
      'pageSize': pageSize.toString()
    };
    Uri url = Uri.https(baseUrl, endpoint, query);

    var resp = await _client.get(url);
    Map body = jsonDecode(resp.body);

    List<Tweet> moreItems = [];

    switch (resp.statusCode) {
      case HttpStatus.ok:
        for (var t in body['data']) {
          moreItems.add(Tweet.fromJson(t));
        }
        print('Success calling getFeed');
        break;
      default:
        print('Error calling getFeed. Code: ${resp.statusCode}');
    }

    return moreItems;
  }

  @override
  Future<List<Tweet>> getStory(String userId,
      {String lastKey, int pageSize = 10}) async {
    var endpoint = apiVersion + storyEndpoint + '/$userId';
    Map<String, String> query = {
      'lastKey': lastKey,
      'pageSize': pageSize.toString()
    };
    Uri url = Uri.https(baseUrl, endpoint, query);

    var resp = await _client.get(url);
    Map body = jsonDecode(resp.body);
    List<Tweet> moreItems = [];

    switch (resp.statusCode) {
      case HttpStatus.ok:
        for (var t in body['data']) {
          moreItems.add(Tweet.fromJson(t));
        }
        print('Success calling getStory');
        break;
      default:
        print('Error calling getStory. Code: ${resp.statusCode}');
    }

    return moreItems;
  }

  @override
  Future<List<Tweet>> getTweetsByHashtag(String word,
      {String lastKey, int pageSize = 10}) async {
    var endpoint = apiVersion + hashtagTweetsEndpoint + '/$word';
    Map<String, String> query = {
      'lastKey': lastKey,
      'pageSize': pageSize.toString()
    };
    Uri url = Uri.https(baseUrl, endpoint, query);

    var resp = await _client.get(url);
    Map body = jsonDecode(resp.body);
    List<Tweet> moreItems = [];

    switch (resp.statusCode) {
      case HttpStatus.ok:
        for (var t in body['data']) {
          moreItems.add(Tweet.fromJson(t));
        }
        print('Success calling getTweetsByHashtag');
        break;
      default:
        print('Error calling getTweetsByHashtag. Code: ${resp.statusCode}');
    }

    return moreItems;
  }

  @override
  Future<List<User>> getFollowers(String userId,
      {String lastKey, int pageSize = 10}) async {
    var endpoint = apiVersion + followersEndpoint + '/$userId';
    Map<String, String> query = {
      'lastKey': lastKey,
      'pageSize': pageSize.toString()
    };
    Uri url = Uri.https(baseUrl, endpoint, query);

    var resp = await _client.get(url);
    Map body = jsonDecode(resp.body);
    List<User> moreItems = [];

    switch (resp.statusCode) {
      case HttpStatus.ok:
        for (var u in body['data']) {
          moreItems.add(User.fromJson(u));
        }
        print('Success calling getFollowers');
        break;
      default:
        print('Error calling getFollowers. Code: ${resp.statusCode}');
    }
    return moreItems;
  }

  @override
  Future<List<User>> getFollowing(String userId,
      {String lastKey, int pageSize = 10}) async {
    var endpoint = apiVersion + followingEndpoint + '/$userId';
    Map<String, String> query = {
      'lastKey': lastKey,
      'pageSize': pageSize.toString()
    };
    Uri url = Uri.https(baseUrl, endpoint, query);

    var resp = await _client.get(url);
    Map body = jsonDecode(resp.body);
    List<User> moreItems = [];

    switch (resp.statusCode) {
      case HttpStatus.ok:
        for (var u in body['data']) {
          moreItems.add(User.fromJson(u));
        }
        print('Success calling getFollowing');
        break;
      default:
        print('Error calling getFollowing. Code: ${resp.statusCode}');
    }
    return moreItems;
  }

  Future<String> _uploadMedia(File media, String userId) async {
    print('uploading media');
    var endpoint = apiVersion + mediaEndpoint;
    Uri url = Uri.https(baseUrl, endpoint);
    String encoded = base64Encode(media.readAsBytesSync());
    String mimeType = lookupMimeType(media.path);
    String ext = p.extension(media.path);

    Map headers = {
      HttpHeaders.contentTypeHeader: mimeType,
    };

    Map<String, String> params = {
      'userId': userId,
      'mimeType': mimeType,
      'extension': ext,
      'encodedMedia': encoded,
      'isBase64Encoded': true.toString()
    };

    var resp = await _client.post(url, body: jsonEncode(params));

    String mediaUrl;
    switch (resp.statusCode) {
      case HttpStatus.ok:
        Map body = jsonDecode(resp.body);
        mediaUrl = body['url'];
        break;
      default:
        print('Bad http request, unable to upload media');
    }

    print('Finished uploading media');

    return mediaUrl;
  }
}
