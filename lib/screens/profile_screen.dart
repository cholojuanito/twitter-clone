import 'dart:io';

import 'package:flutter/material.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/theme/color.dart';
import 'package:twitter_clone/theme/icons.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/follow_vm.dart';
import 'package:twitter_clone/vms/tweet_vm.dart';
import 'package:twitter_clone/vms/list_view_vms.dart';
import 'package:twitter_clone/vms/profile_vm.dart';
import 'package:twitter_clone/widgets/tweet_list_item.dart';
import 'package:twitter_clone/widgets/user_list_item.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  TabController _tabController;
  final int _NUM_TABS = 4;
  Api _api;
  ProfileVM _vm;
  AuthenticationService _auth;
  // These are for referencing from the scroll listeners
  ListViewVM _feedVM;
  ListViewVM _storyVM;
  ListViewVM _followersVM;
  ListViewVM _followingVM;

  ScrollController _feedScrollCntrlr;
  ScrollController _storyScrollCntrlr;
  ScrollController _followersScrollCntrlr;
  ScrollController _followingScrollCntrlr;

  @override
  void initState() {
    super.initState();
    _feedScrollCntrlr = ScrollController();
    _storyScrollCntrlr = ScrollController();
    _followersScrollCntrlr = ScrollController();
    _followingScrollCntrlr = ScrollController();

    _feedScrollCntrlr.addListener(_feedScrollListener);
    _storyScrollCntrlr.addListener(_storyScrollListener);
    _followersScrollCntrlr.addListener(_followersScrollListener);
    _followingScrollCntrlr.addListener(_followingScrollListener);

    _tabController = TabController(length: _NUM_TABS, vsync: this);
  }

  @override
  void dispose() {
    _feedScrollCntrlr?.removeListener(_feedScrollListener);
    _storyScrollCntrlr?.removeListener(_storyScrollListener);
    _followersScrollCntrlr?.removeListener(_followersScrollListener);
    _followingScrollCntrlr?.removeListener(_followingScrollListener);

    _feedScrollCntrlr?.dispose();
    _storyScrollCntrlr?.dispose();
    _followersScrollCntrlr?.dispose();
    _followingScrollCntrlr?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: <Widget>[
        Tab(text: 'Feed'),
        Tab(text: 'Story'),
        Tab(text: 'Followers'),
        Tab(text: 'Following'),
      ],
      indicator: MD2Indicator(
        indicatorHeight: 4,
        indicatorColor: TwitterColor.white,
        indicatorSize: MD2IndicatorSize.full,
      ),
    );
  }

  Widget _buildTweetList(bool isFeed) {
    return Consumer<TweetListVM>(
      builder: (context, vm, child) {
        var items = vm.items;
        return ListView.builder(
          controller: isFeed ? _feedScrollCntrlr : _storyScrollCntrlr,
          itemCount: items.length + 1,
          itemBuilder: (context, idx) {
            if (items.isEmpty) {
              return _buildEmptyListText();
            } else if (idx == items.length) {
              return _buildProgressIndicator(isFeed ? _feedVM : _storyVM);
            } else {
              var _tweetVm = TweetVM(items.elementAt(idx), _api);
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
    );
  }

  Widget _buildFollowingList(bool isFollowersList) {
    return Consumer<FollowingListVM>(
      builder: (context, vm, _) {
        return FutureBuilder(
          future: vm.initUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                var items = vm.items;
                return ListView.builder(
                  itemCount: vm.users.length + 1,
                  itemBuilder: (context, idx) {
                    if (items.isEmpty) {
                      return _buildEmptyListText();
                    } else if (idx == items.length) {
                      return _buildProgressIndicator(
                          isFollowersList ? _followersVM : _followingVM);
                    } else {
                      var u = vm.users.elementAt(idx);
                      var f = isFollowersList
                          ? items.firstWhere((f) => u.id == f.followerId,
                              orElse: null)
                          : items.firstWhere((f) => u.id == f.followeeId,
                              orElse: null);
                      return ChangeNotifierProvider<FollowingVM>(
                        builder: (_) => FollowingVM(
                          _auth.getCurrentUser(),
                          u,
                          _api,
                          theFollowing: f,
                        ),
                        child: UserListItem(),
                      );
                    }
                  },
                );
                break;
              default:
                return Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    _vm = Provider.of<ProfileVM>(context);
    _auth = Provider.of<AuthenticationService>(context);
    _api = Provider.of<Api>(context);
    // For checking if the user profile to display is that of the
    // currently logged in user
    bool _isLoggedInUser = _vm.user.alias == _auth.getCurrentUser()?.alias;

    _feedVM =
        TweetListVM(_vm.user.feed.tweets, _auth, _api, TweetListType.feed);
    _storyVM =
        TweetListVM(_vm.user.story.tweets, _auth, _api, TweetListType.story);
    _followersVM = FollowingListVM(
        _vm.user.followers, _auth, _api, FollowListType.followers);
    _followingVM = FollowingListVM(
        _vm.user.following, _auth, _api, FollowListType.following);

    return Scaffold(
      appBar: AppBar(
        leading: _isLoggedInUser
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: CircleAvatar(
                  backgroundImage:
                      _vm.user.profilePic.route == User.defaultProfileURL
                          ? AssetImage(_vm.user.profilePic.route)
                          : FileImage(
                              File(_vm.user.profilePic.route),
                            ), //TODO change to network
                ),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => appNavKey.currentState.pop(context),
              ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_vm.user.fullName),
            // Text('${_vm.user.story.tweets.length} tweets')
          ],
        ),
        actions: _isLoggedInUser
            ? <Widget>[
                IconButton(
                  // TODO implement search
                  icon: Icon(OMIcons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(OMIcons.exitToApp),
                  onPressed: () {
                    _auth.signOut();
                    appNavKey.currentState.popAndPushNamed(initialRoute);
                  },
                ),
              ]
            : <Widget>[],
        bottom: _buildTabBar(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ChangeNotifierProvider<TweetListVM>.value(
            value: _feedVM,
            child: _buildTweetList(true),
          ),
          ChangeNotifierProvider<TweetListVM>.value(
            value: _storyVM,
            child: _buildTweetList(false),
          ),
          ChangeNotifierProvider<FollowingListVM>.value(
            value: _followersVM,
            child: _buildFollowingList(true),
          ),
          ChangeNotifierProvider<FollowingListVM>.value(
            value: _followingVM,
            child: _buildFollowingList(false),
          ),
        ],
      ),
      floatingActionButton: _isLoggedInUser
          ? FloatingActionButton(
              backgroundColor: TwitterColor.cerulean,
              child: Icon(
                TwitterIcons.newTweetFilled,
                color: TwitterColor.white,
              ),
              onPressed: () {
                appNavKey.currentState.pushNamed(
                  createTweetRoute,
                  arguments: CreateTweetRouteArguments(
                    _auth.getCurrentUser(),
                  ),
                );
              },
            )
          : Container(),
    );
  }

  void _feedScrollListener() {
    if (_feedScrollCntrlr.position.pixels ==
        _feedScrollCntrlr.position.maxScrollExtent) {
      _feedVM.getMoreItems();
    }
  }

  void _storyScrollListener() {
    if (_storyScrollCntrlr.position.pixels ==
        _storyScrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _storyVM.getMoreItems();
      }
    }
  }

  void _followersScrollListener() {
    if (_followersScrollCntrlr.position.pixels ==
        _followersScrollCntrlr.position.maxScrollExtent) {
      _vm.setLoadingState(true);
      _followersVM.getMoreItems().then((resp) => _vm.setLoadingState(false));
    }
  }

  void _followingScrollListener() {
    if (_followingScrollCntrlr.position.pixels ==
        _followingScrollCntrlr.position.maxScrollExtent) {
      _vm.setLoadingState(true);
      _followingVM.getMoreItems().then((resp) => _vm.setLoadingState(false));
    }
  }
}
