import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/theme/color.dart';
import 'package:twitter_clone/util/router.dart';

import 'package:twitter_clone/vms/auth_vm.dart';

class LoginScreen extends StatefulWidget {
  final AuthenticationService service;

  LoginScreen(this.service);

  @override
  _LoginScreenState createState() => _LoginScreenState(service);
}

class _LoginScreenState extends State<LoginScreen> {
  AuthenticationService authService;
  _LoginScreenState(this.authService);

  BuildContext _context;

  TextEditingController _loginAliasCntrlr;
  TextEditingController _loginPasswordCntrlr;
  TextEditingController _signUpAliasCntrlr;
  TextEditingController _signUpNameCntrlr;
  TextEditingController _signUpPasswordCntrlr;

  @override
  void initState() {
    authService.getCurrentUserAsync().then((user) {
      if (user != null) {
        Crashlytics.instance.setUserIdentifier(user.id);
        Crashlytics.instance.setUserName(user.fullName);
        appNavKey.currentState.pushNamed(homeRoute);
      }
    });

    _loginAliasCntrlr = TextEditingController();
    _loginPasswordCntrlr = TextEditingController();
    _signUpAliasCntrlr = TextEditingController();
    _signUpNameCntrlr = TextEditingController();
    _signUpPasswordCntrlr = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _loginAliasCntrlr?.dispose();
    _loginPasswordCntrlr?.dispose();
    _signUpAliasCntrlr?.dispose();
    _signUpNameCntrlr?.dispose();
    _signUpPasswordCntrlr?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return Scaffold(
      body: Consumer<AuthVM>(
        builder: (context, vm, _) {
          return Center(
            child: !vm.isLoading
                ? Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: _loginAliasCntrlr,
                            decoration: InputDecoration(
                              labelText: 'Alias',
                              prefix: Text('@'),
                            ),
                          ),
                        ),
                        Container(
                          child: TextField(
                            controller: _loginPasswordCntrlr,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                        ),
                        MaterialButton(
                          child: Text('Login'),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            vm
                                .login(
                              _loginAliasCntrlr.text,
                              _loginPasswordCntrlr.text,
                            )
                                .then(
                              (resp) {
                                // Reroute to the 'home' Profile Screen
                                if (resp.status == 0) {
                                  Crashlytics.instance.setUserIdentifier(
                                      vm.getCurrentUser().id);
                                  Crashlytics.instance.setUserName(
                                      vm.getCurrentUser().fullName);
                                  appNavKey.currentState
                                      .pushReplacementNamed(homeRoute);
                                } else {
                                  Scaffold.of(this._context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resp.message,
                                      ),
                                      backgroundColor: TwitterColor.ceriseRed,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GestureDetector(
                            child: Text('Sign up here'),
                            onTap: () {
                              appNavKey.currentState.pushNamed(signUpRoute);
                            },
                          ),
                        )
                      ],
                    ),
                  )
                : Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Logging in'),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
