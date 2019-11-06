import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/tweet.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/theme/color.dart';
import 'package:twitter_clone/theme/icons.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/auth_vm.dart';
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
  AuthVM _auth;

  ScrollController _feedScrollCntrlr;
  ScrollController _storyScrollCntrlr;
  ScrollController _followersScrollCntrlr;
  ScrollController _followingScrollCntrlr;

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<ProfileVM>(context, listen: false);
    _vm.getInitialFeed();
    _vm.getInitialStory();
    _vm.getInitialFollowers();
    _vm.getInitialFollowing();

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

  Future _takeImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    this._vm.changeProfilePic(image.path).then((res) {
      var message = 'An error occurred. Could not update profile picture';
      if (res) {
        message = 'Profile picture updated';
      }

      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //   ),
      // );
    });

    appNavKey.currentState.pop(); // Close modal
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    this._vm.changeProfilePic(image.path);

    appNavKey.currentState.pop(); // Close modal
  }

  Widget _buildBottomSheet(BuildContext context) {
    // TODO Make into own widget class?
    var _size = MediaQuery.of(context).size;
    return Container(
      height: _size.height * 0.33333,
      // margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Container(
            width: _size.width,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Change profile picture:',
              style: TextStyle(
                color: TwitterColor.black,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: _size.width,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    OMIcons.cameraAlt,
                    size: 32.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Take a picture',
                      style: TextStyle(
                        color: TwitterColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              _takeImage();
            },
          ),
          Divider(
            thickness: 2.0,
            height: 5.0,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    OMIcons.photoLibrary,
                    size: 32.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Select from gallery',
                      style: TextStyle(
                        color: TwitterColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              _getImage();
            },
          ),
        ],
      ),
    );
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
    List<Tweet> items = isFeed ? _vm.feed.tweets : _vm.story.tweets;
    return ListView.builder(
      controller: isFeed ? _feedScrollCntrlr : _storyScrollCntrlr,
      itemCount: items.length + 1,
      itemBuilder: (context, idx) {
        if (items.isEmpty) {
          return _buildEmptyListText();
        } else if (idx == items.length) {
          return _buildProgressIndicator();
        } else {
          var t = items.elementAt(idx);
          var _tweetVm = isFeed
              ? TweetVM(t, _vm.tweetAuthors[t.id], _api)
              : TweetVM(t, _vm.user, _api);
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
    // return FutureBuilder(
    //   future: isFeed ? _vm.getInitialFeed() : _vm.getInitialStory(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.done:
    //         if (snapshot.hasError) {
    //           return Center(
    //             child: Text('Something bad happened'),
    //           );
    //         } else if (snapshot.hasData && !snapshot.hasError) {
    //           List<Tweet> items = isFeed ? _vm.feed.tweets : _vm.story.tweets;
    //           return ListView.builder(
    //             controller: isFeed ? _feedScrollCntrlr : _storyScrollCntrlr,
    //             itemCount: items.length + 1,
    //             itemBuilder: (context, idx) {
    //               if (items.isEmpty) {
    //                 return _buildEmptyListText();
    //               } else if (idx == items.length) {
    //                 return _buildProgressIndicator();
    //               } else {
    //                 var t = items.elementAt(idx);
    //                 var _tweetVm = isFeed
    //                     ? TweetVM(t, _vm.tweetAuthors[t.id], _api)
    //                     : TweetVM(t, _vm.user, _api);
    //                 return ChangeNotifierProvider<TweetVM>.value(
    //                   value: _tweetVm,
    //                   child: _tweetVm.tweet.media != null
    //                       ? TweetListItem(
    //                           mediaPath: _tweetVm.tweet.media.route,
    //                           type: _tweetVm.tweet.media.type,
    //                         )
    //                       : TweetListItem(),
    //                 );
    //               }
    //             },
    //           );
    //         }
    //         break;
    //       case ConnectionState.active:
    //       case ConnectionState.waiting:
    //       // case ConnectionState.none:
    //       default:
    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //     }
    //   },
    // );
  }

  Widget _buildFollowingList(bool isFollowersList) {
    var items = isFollowersList ? _vm.followersUsers : _vm.followingUsers;
    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, idx) {
        if (items.isEmpty) {
          return _buildEmptyListText();
        } else if (idx == items.length) {
          return _buildProgressIndicator();
        } else {
          var u = items.elementAt(idx);
          return ChangeNotifierProvider<FollowingVM>(
            builder: (_) => FollowingVM(
              _vm.loggedInUser,
              u,
              _api,
              // theFollowing: f,
            ),
            child: UserListItem(),
          );
        }
      },
    );
    // return Consumer<FollowingListVM>(
    //   builder: (context, vm, _) {
    //     return FutureBuilder(
    //       future: vm.initUsers(),
    //       builder: (context, snapshot) {
    //         switch (snapshot.connectionState) {
    //           case ConnectionState.done:
    //             var items = vm.items;
    //             return ListView.builder(
    //               itemCount: vm.users.length + 1,
    //               itemBuilder: (context, idx) {
    //                 if (items.isEmpty) {
    //                   return _buildEmptyListText();
    //                 } else if (idx == items.length) {
    //                   return _buildProgressIndicator();
    //                 } else {
    //                   var u = vm.users.elementAt(idx);
    //                   var f = isFollowersList
    //                       ? items.firstWhere((f) => u.id == f.followerId,
    //                           orElse: null)
    //                       : items.firstWhere((f) => u.id == f.followeeId,
    //                           orElse: null);
    //                   return ChangeNotifierProvider<FollowingVM>(
    //                     builder: (_) => FollowingVM(
    //                       _vm.loggedInUser,
    //                       u,
    //                       _api,
    //                       theFollowing: f,
    //                     ),
    //                     child: UserListItem(),
    //                   );
    //                 }
    //               },
    //             );
    //             break;
    //           default:
    //             return Center(
    //               child: CircularProgressIndicator(),
    //             );
    //         }
    //       },
    //     );
    //   },
    // );
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
    _auth = Provider.of<AuthVM>(context);
    _api = Provider.of<Api>(context);

    return Scaffold(
      appBar: AppBar(
        leading: _vm.isHomeScreen
            ? GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: _buildBottomSheet,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: CircleAvatar(
                    backgroundImage:
                        _vm.user.profilePic.route == User.defaultProfileURL
                            ? AssetImage(_vm.user.profilePic.route)
                            : NetworkImage(
                                _vm.user.profilePic.route,
                              ),
                  ),
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
        actions: _vm.isHomeScreen
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
          _buildTweetList(true),
          _buildTweetList(false),
          _buildFollowingList(true),
          _buildFollowingList(false),
        ],
      ),
      floatingActionButton: _vm.isHomeScreen
          ? FloatingActionButton(
              backgroundColor: TwitterColor.cerulean,
              child: Icon(
                TwitterIcons.newTweetFilled,
                color: TwitterColor.white,
              ),
              onPressed: () {
                appNavKey.currentState
                    .pushNamed<Tweet>(
                  createTweetRoute,
                  arguments: CreateTweetRouteArguments(
                    _vm.loggedInUser,
                  ),
                )
                    .then((Tweet ret) {
                  _vm.addMoreToStory([ret]);
                });
              },
            )
          : Container(),
    );
  }

  void _feedScrollListener() {
    if (_feedScrollCntrlr.position.pixels ==
        _feedScrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _vm.getMoreFeed();
      }
    }
  }

  void _storyScrollListener() {
    if (_storyScrollCntrlr.position.pixels ==
        _storyScrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _vm.getMoreStory();
      }
    }
  }

  void _followersScrollListener() {
    if (_followersScrollCntrlr.position.pixels ==
        _followersScrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _vm.getMoreFollowers();
      }
    }
  }

  void _followingScrollListener() {
    if (_followingScrollCntrlr.position.pixels ==
        _followingScrollCntrlr.position.maxScrollExtent) {
      if (!_vm.isLoading) {
        _vm.getMoreFollowing();
      }
    }
  }
}
