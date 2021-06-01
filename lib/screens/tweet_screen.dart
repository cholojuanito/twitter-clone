import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/vms/tweet_vm.dart';
import 'package:twitter_clone/widgets/video_aspect_ratio.dart';
import 'package:video_player/video_player.dart';

class TweetScreen extends StatefulWidget {
  final String mediaPath;
  final MediaType type;

  TweetScreen({this.mediaPath, this.type});

  @override
  _TweetScreenState createState() =>
      mediaPath != null ? _TweetScreenState() : _TweetScreenState();
}

class _TweetScreenState extends State<TweetScreen> {
  VideoPlayerController _videoCntrlr;
  Future<void> _initVideoPlayerFuture;

  _TweetScreenState();

  @override
  void initState() {
    if (this.widget.mediaPath != null && this.widget.type == MediaType.Video) {
      this._videoCntrlr = VideoPlayerController.network(this.widget.mediaPath);
      this._initVideoPlayerFuture = _videoCntrlr.initialize();
      this._videoCntrlr.setLooping(true);
      this._videoCntrlr.setVolume(1.0);
    }
    super.initState();
  }

  @override
  void deactivate() {
    _videoCntrlr?.setVolume(0.0);
    _videoCntrlr?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    await _videoCntrlr?.dispose();
    _videoCntrlr = null;
  }

  Future<void> _playVideo() async {
    if (this._videoCntrlr != null && mounted) {
      await _videoCntrlr.play();
      setState(() {});
    }
  }

  Widget _showVideo() {
    return FutureBuilder(
      future: _initVideoPlayerFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return AspectRatioVideo(_videoCntrlr);
            break;
          default:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text('Loading video...'),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
      },
    );
  }

  Widget _showImage() {
    return Image.network(
      this.widget.mediaPath,
      fit: BoxFit.cover,
    );
  }

  Widget _buildMediaWidget(double h, double w, bool isImage) {
    return Container(
      height: h,
      width: w,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: isImage ? _showImage() : _showVideo(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tweet'),
      ),
      body: Consumer<TweetVM>(
        builder: (context, vm, child) {
          this._playVideo();
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: ScrollController(),
                physics: ScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 8.0),
                            child: CircleAvatar(
                              maxRadius: 32.0,
                              backgroundImage: vm.author.profilePic.route ==
                                      User.defaultProfileURL
                                  ? AssetImage(vm.author.profilePic.route)
                                  : NetworkImage(vm.author.profilePic.route),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    '${vm.author.fullName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    '@${vm.author.alias}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              child: vm.linkedMessage,
                            ),
                          )
                        ],
                      ),
                      vm.tweet?.media?.route != null
                          ? _buildMediaWidget(
                              constraints.maxHeight * 0.9,
                              constraints.maxWidth * 0.9,
                              vm.tweet.media.type == MediaType.Image,
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
