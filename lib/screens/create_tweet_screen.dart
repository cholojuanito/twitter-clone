import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:twitter/models/linked_items.dart';
import 'package:twitter/theme/color.dart';
import 'package:twitter/theme/icons.dart';
import 'package:twitter/util/router.dart';
import 'package:twitter/vms/create_tweet_vm.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thumbnails/thumbnails.dart';

class CreateTweetScreen extends StatefulWidget {
  @override
  _CreateTweetScreenState createState() => _CreateTweetScreenState();
}

class _CreateTweetScreenState extends State<CreateTweetScreen> {
  // Media
  File _mediaFile;
  bool _isVideo = false;
  String _videoThumbnailPath;
  var _pickImageError;

  // Message
  TextEditingController _tweetCntrlr;
  bool _canTweet = false;

  @override
  void initState() {
    _tweetCntrlr = TextEditingController();
    _tweetCntrlr.addListener(_tweetMessageListener);
    super.initState();
  }

  // TODO these might go in the VM?
  Future _takeImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _isVideo = false;
      _mediaFile = image;
    });
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _isVideo = false;
      _mediaFile = image;
    });
  }

  Future _getVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    var _dir = await getApplicationDocumentsDirectory();
    var _dirPath = _dir.path;
    Thumbnails.getThumbnail(
      videoFile: video.path,
      thumbnailFolder: _dirPath,
      imageType: ThumbFormat.PNG,
      quality: 50,
    ).then((thumbPath) {
      setState(() {
        _isVideo = true;
        _mediaFile = video;
        _videoThumbnailPath = thumbPath;
      });
    });
  }

  void _tweetMessageListener() {
    if (_tweetCntrlr.text.isNotEmpty) {
      setState(() {
        _canTweet = true;
      });
    } else {
      setState(() {
        _canTweet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTweetVM>(
      builder: (context, vm, _) {
        var _deviceSize = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            actions: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  color: TwitterColor.dodgetBlue,
                  onPressed: _canTweet
                      ? () {
                          vm
                              .create(
                            _tweetCntrlr.text,
                            mediaPath: _mediaFile?.path,
                            type: _isVideo ? MediaType.Video : MediaType.Image,
                          )
                              .then(
                            (res) => appNavKey.currentState.pop(context),
                            onError: (e) {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Something bad happened!'),
                                ),
                              );
                            },
                          );
                        }
                      : null,
                  child: Text(
                    'Tweet',
                    style: TextStyle(
                      color: TwitterColor.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0, bottom: 70.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: _tweetCntrlr,
                            autofocus: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            // maxLength: 280,
                            style: TextStyle(
                              color: TwitterColor.black,
                              fontFamily: "ProductSans",
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(0.0),
                              labelText: 'What\'s happening?',
                              labelStyle: TextStyle(
                                color: TwitterColor.woodsmoke,
                              ),
                            ),
                          ),
                        ),
                        _mediaFile != null
                            ? Container(
                                height: _deviceSize.height * 0.5,
                                width: _deviceSize.width * 0.5,
                                // Image preview
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _isVideo
                                        ? FileImage(File(_videoThumbnailPath))
                                        : FileImage(_mediaFile),
                                  ),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                      right: 0.0,
                                      top: 0.0,
                                      child: IconButton(
                                        icon: Icon(OMIcons.close),
                                        color: TwitterColor.white,
                                        onPressed: () {
                                          setState(() {
                                            _mediaFile = null;
                                          });
                                        },
                                      ),
                                    ),
                                    _isVideo
                                        ? Positioned(
                                            top: 0.0,
                                            left: 0.0,
                                            child: IconButton(
                                              icon: Icon(
                                                OMIcons.videocam,
                                                color: TwitterColor.white,
                                              ),
                                              onPressed: null,
                                            ),
                                          )
                                        : Positioned(
                                            top: 0.0,
                                            left: 0.0,
                                            child: IconButton(
                                              icon: Icon(
                                                OMIcons.photoLibrary,
                                                color: TwitterColor.white,
                                              ),
                                              onPressed: null,
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 1.0,
                              ), // Image container
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          bottomSheet: Container(
            height: 60.0,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: TwitterColor.woodsmoke_50,
                  width: 0.25,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      OMIcons.cameraAlt,
                    ),
                    color: TwitterColor.cerulean,
                    disabledColor: TwitterColor.mystic,
                    iconSize: 32.0,
                    tooltip: 'Take a photo',
                    onPressed: _mediaFile == null ? _onTakeImagePressed : null,
                  ),
                  IconButton(
                    icon: Icon(
                      OMIcons.photoLibrary,
                    ),
                    color: TwitterColor.cerulean,
                    disabledColor: TwitterColor.mystic,
                    iconSize: 32.0,
                    tooltip: 'Pick a photo',
                    onPressed: _mediaFile == null ? _onGetImagePressed : null,
                  ),
                  IconButton(
                    icon: Icon(
                      OMIcons.videocam,
                    ),
                    color: TwitterColor.cerulean,
                    disabledColor: TwitterColor.mystic,
                    iconSize: 32.0,
                    tooltip: 'Pick a video',
                    onPressed: _mediaFile == null ? _onGetVideoPressed : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTakeImagePressed() async {
    try {
      await _takeImage();
    } catch (e) {
      _pickImageError = e;
    }
  }

  void _onGetImagePressed() async {
    try {
      await _getImage();
    } catch (e) {
      _pickImageError = e;
    }
  }

  void _onGetVideoPressed() async {
    try {
      await _getVideo();
    } catch (e) {
      _pickImageError = e;
    }
  }
}
