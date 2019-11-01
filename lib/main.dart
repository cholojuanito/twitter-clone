import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/screens/login_screen.dart';
import 'package:twitter_clone/dummy_data.dart' as db;
import 'package:twitter_clone/services/api.dart';
import 'package:twitter_clone/services/authentication.dart';
import 'package:twitter_clone/services/aws_api.dart';
import 'package:twitter_clone/services/firebase_auth.dart';
import 'package:twitter_clone/util/router.dart';
import 'package:twitter_clone/vms/auth_vm.dart';

void main() {
  // Change AuthService and Api implementations here
  final AuthenticationService _authService = FirebaseAuthenticationService();
  final Api _twitterApi = AWSTwitterApi(_authService);
  _authService..api = _twitterApi;
  db.initDummyData();
  runApp(TwitterClone(_twitterApi, _authService));
}

class TwitterClone extends StatelessWidget {
  final AuthenticationService _authService;
  final Api _twitterApi;

  TwitterClone(this._twitterApi, this._authService);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Api>.value(
          value: _twitterApi,
        ),
        ChangeNotifierProvider.value(
          value: _authService,
        ),
      ],
      child: Consumer<AuthenticationService>(
        builder: (context, service, _) {
          return Provider<AuthVM>(
            builder: (_) => AuthVM(service),
            child: MaterialApp(
              title: 'Twitter',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: LoginScreen(),
              onGenerateRoute: generateRoute,
              initialRoute: initialRoute,
              navigatorKey: appNavKey,
            ),
          );
        },
      ),
    );
  }
}
