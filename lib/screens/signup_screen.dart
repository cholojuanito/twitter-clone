import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/theme/color.dart';
import 'package:twitter_clone/theme/icons.dart';
import 'package:twitter_clone/util/router.dart';

import 'package:twitter_clone/vms/auth_vm.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _signUpAliasCntrlr;
  TextEditingController _signUpNameCntrlr;
  TextEditingController _signUpPasswordCntrlr;
  bool _canSignUp = false;

  File _profilePic;
  var _pickImageError;

  Future _takeImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    appNavKey.currentState.pop(); // Close modal
    setState(() {
      _profilePic = image;
    });
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    appNavKey.currentState.pop(); // Close modal
    setState(() {
      _profilePic = image;
    });
  }

  @override
  void initState() {
    _signUpAliasCntrlr = TextEditingController();
    _signUpNameCntrlr = TextEditingController();
    _signUpPasswordCntrlr = TextEditingController();

    _signUpAliasCntrlr.addListener(_changeListener);
    _signUpNameCntrlr.addListener(_changeListener);
    _signUpPasswordCntrlr.addListener(_changeListener);

    super.initState();
  }

  @override
  void dispose() {
    _signUpAliasCntrlr.removeListener(_changeListener);
    _signUpNameCntrlr.removeListener(_changeListener);
    _signUpPasswordCntrlr.removeListener(_changeListener);

    _signUpAliasCntrlr?.dispose();
    _signUpNameCntrlr?.dispose();
    _signUpPasswordCntrlr?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Consumer<AuthVM>(builder: (context, vm, _) {
              return Center(
                child: !vm.isLoading
                    ? Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    child: CircleAvatar(
                                      maxRadius: constraints.maxHeight * 0.15,
                                      backgroundImage: _profilePic != null
                                          ? FileImage(_profilePic)
                                          : AssetImage(User.defaultProfileURL),
                                    ),
                                  ),
                                  Positioned(
                                    right: 5.0,
                                    bottom: 5.0,
                                    child: GestureDetector(
                                      child: Container(
                                        width: constraints.maxHeight * 0.075,
                                        height: constraints.maxHeight * 0.075,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: TwitterColor.mystic,
                                          border: Border.all(
                                            width: 2.5,
                                            color: TwitterColor.white,
                                          ),
                                        ),
                                        child: Icon(
                                          OMIcons.cameraAlt,
                                          color: TwitterColor.black,
                                        ),
                                      ),
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: _buildBottomSheet,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: TextField(
                                controller: _signUpNameCntrlr,
                                decoration: InputDecoration(
                                  labelText: 'Full name',
                                ),
                              ),
                            ),
                            Container(
                              child: TextField(
                                controller: _signUpAliasCntrlr,
                                decoration: InputDecoration(
                                  labelText: 'Alias',
                                  prefix: Text('@'),
                                ),
                              ),
                            ),
                            Container(
                              child: TextField(
                                controller: _signUpPasswordCntrlr,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                ),
                              ),
                            ),
                            MaterialButton(
                              child: Text('Sign Up'),
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: _canSignUp
                                  ? () {
                                      _performSignUp(vm);
                                    }
                                  : null,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: GestureDetector(
                                child: Text('Login here'),
                                onTap: () {
                                  appNavKey.currentState.pop();
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text('Creating profile'),
                        ],
                      ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    // TODO Make into own widget class?
    var _size = MediaQuery.of(context).size;
    return Container(
      height: 150.0,
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
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

  void _performSignUp(AuthVM vm) async {
    vm
        .signUp(
      _signUpNameCntrlr.text,
      _signUpAliasCntrlr.text,
      _signUpPasswordCntrlr.text,
      profilePicPath: _profilePic != null ? _profilePic.path : null,
    )
        .then(
      (resp) {
        // Reroute to the 'home' Profile Screen
        if (resp.status == 0) {
          Crashlytics.instance.setUserIdentifier(vm.getCurrentUser().id);
          Crashlytics.instance.setUserName(vm.getCurrentUser().fullName);
          appNavKey.currentState.pushReplacementNamed(homeRoute);
        }
      },
    );
  }

  void _changeListener() {
    if (_signUpNameCntrlr.text.isNotEmpty &&
        _signUpAliasCntrlr.text.isNotEmpty &&
        _signUpPasswordCntrlr.text.isNotEmpty) {
      setState(() {
        _canSignUp = true;
      });
    } else {
      setState(() {
        _canSignUp = false;
      });
    }
  }
}
