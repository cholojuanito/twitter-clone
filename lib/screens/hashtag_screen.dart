import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/vms/hashtag_vm.dart';
import 'package:twitter_clone/vms/list_view_vms.dart';
import 'package:twitter_clone/vms/tweet_vm.dart';
import 'package:twitter_clone/widgets/tweet_list_item.dart';

class HashtagScreen extends StatefulWidget {
  @override
  _HashtagScreenState createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  ScrollController _scrollCntrlr;
  HashtagVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<HashtagVM>(context, listen: false);
    _vm.getInitialTweets();

    _scrollCntrlr = ScrollController();
    _scrollCntrlr.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollCntrlr?.removeListener(_scrollListener);
    _scrollCntrlr?.dispose();

    super.dispose();
  }

  Widget _buildEmptyListText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No data to show',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: _vm.isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _vm = Provider.of<HashtagVM>(context);
    List<Tweet> items = _vm.tweets;
    return Scaffold(
      appBar: AppBar(
        title: Text('#${_vm.word}'),
      ),
      body: _vm.isLoading
          ? _buildProgressIndicator()
          : ListView.builder(
              controller: _scrollCntrlr,
              itemCount: items.length + 1,
              itemBuilder: (context, idx) {
                if (items.isEmpty) {
                  return _buildEmptyListText();
                } else if (idx == items.length) {
                  return _buildProgressIndicator();
                } else {
                  var t = items.elementAt(idx);
                  var _tweetVm = TweetVM(t, _vm.tweetAuthors[t.id], _vm.api);
                  return ChangeNotifierProvider<TweetVM>.value(
                    value: _tweetVm,
                    child: _tweetVm.tweet.media != null
                        ? TweetListItem(
                            mediaPath: _tweetVm.tweet.media.route,
                            type: _tweetVm.tweet.media.type,
                          )
                        : TweetListItem(),
                  );
                }
              },
            ),
    );
  }

  void _scrollListener() {
    if (_scrollCntrlr.position.pixels ==
        _scrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _vm.getMoreTweets();
      }
    }
  }
}
