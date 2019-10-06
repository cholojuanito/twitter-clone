import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/util/router.dart';

import 'package:twitter/vms/auth_vm.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _loginAliasCntrlr;
  TextEditingController _loginPasswordCntrlr;
  TextEditingController _signUpAliasCntrlr;
  TextEditingController _signUpNameCntrlr;
  TextEditingController _signUpPasswordCntrlr;

  @override
  void initState() {
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
    return Scaffold(
      body: Center(
        child: Container(
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
              Consumer<AuthVM>(
                builder: (context, vm, _) {
                  return MaterialButton(
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
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(resp.message),
                            ),
                          );

                          // Reroute to the 'home' Profile Screen
                          if (resp.status == 0) {
                            appNavKey.currentState.pushReplacementNamed(
                              profileRoute,
                              arguments: ProfileRouteArguments(
                                vm.getCurrentUser(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Text('Sign up here'),
                  onTap: () {
                    appNavKey.currentState.pushNamed(signUpRoute);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
