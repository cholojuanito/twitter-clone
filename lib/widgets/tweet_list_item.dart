import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/linked_items.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/theme/color.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/tweet_vm.dart';
import 'package:twitter_clone/widgets/video_aspect_ratio.dart';
import 'package:video_player/video_player.dart';

class TweetListItem extends StatefulWidget {
  final String mediaPath;
  final MediaType type;

  TweetListItem({this.mediaPath, this.type});

  @override
  _TweetListItemState createState() =>
      mediaPath != null ? _TweetListItemState() : _TweetListItemState();
}

class _TweetListItemState extends State<TweetListItem> {
  VideoPlayerController _videoCntrlr;
  Future<void> _initVideoPlayerFuture;

  _TweetListItemState();

  @override
  void initState() {
    if (this.widget.mediaPath != null && this.widget.type == MediaType.Video) {
      this._videoCntrlr = VideoPlayerController.network(widget.mediaPath);
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
    await this._videoCntrlr?.dispose();
    this._videoCntrlr = null;
  }

  Future<void> _playVideo() async {
    if (this._videoCntrlr != null && mounted) {
      await this._videoCntrlr.play();
      // setState(() {});
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
    final Size _size = MediaQuery.of(context).size;
    return Consumer<TweetVM>(
      builder: (context, vm, _) {
        if (this._videoCntrlr != null) {
          this._playVideo();
        }
        return Container(
          width: _size.width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: TwitterColor.white,
            border: Border(
              bottom: BorderSide(
                color: TwitterColor.paleSky50,
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              appNavKey.currentState.pushNamed(tweetRoute,
                  arguments: TweetRouteArguments(vm.tweet, vm.author));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: CircleAvatar(
                    backgroundImage:
                        vm.author.profilePic.route == User.defaultProfileURL
                            ? AssetImage(vm.author.profilePic.route)
                            : NetworkImage(vm.author.profilePic.route),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: _size.width * .75,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${vm.author.fullName} ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '@${vm.author.alias} • ${vm.tweet.getCreatedRelativeTime()}',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: _size.width * 0.75,
                      child: vm.linkedMessage,
                    ),
                    vm.tweet?.media?.route != null
                        ? _buildMediaWidget(
                            _size.height * 0.5,
                            _size.width * 0.75,
                            vm.tweet.media.type == MediaType.Image,
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
