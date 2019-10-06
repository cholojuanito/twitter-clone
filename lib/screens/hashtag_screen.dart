import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/vms/list_view_vms.dart';
import 'package:twitter/vms/tweet_vm.dart';
import 'package:twitter/widgets/tweet_list_item.dart';

class HashtagScreen extends StatefulWidget {
  final String word;

  HashtagScreen(this.word);

  @override
  _HashtagScreenState createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {
  ScrollController _scrollCntrlr;
  ListViewVM _hashtagVm;

  @override
  void initState() {
    super.initState();
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
          'No data to show.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ListViewVM listVM) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: listVM.isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.word}'),
      ),
      body: Consumer<TweetListVM>(
        builder: (context, vm, child) {
          _hashtagVm = vm;
          var items = vm.items;
          return ListView.builder(
            controller: _scrollCntrlr,
            itemCount: items.length + 1,
            itemBuilder: (context, idx) {
              if (items.isEmpty) {
                return _buildEmptyListText();
              } else if (idx == items.length) {
                return _buildProgressIndicator(vm);
              } else {
                var _tweetVm = TweetVM(items.elementAt(idx), vm.api);
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
          );
        },
      ),
    );
  }

  void _scrollListener() {
    if (_scrollCntrlr.position.pixels ==
        _scrollCntrlr.position.maxScrollExtent) {
      if (!_hashtagVm.isLoading) {
        _hashtagVm.getMoreItems();
      }
    }
  }
}
