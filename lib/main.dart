import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:twitter/screens/login_screen.dart';
import 'package:twitter/dummy_data.dart' as db;
import 'package:twitter/services/api.dart';
import 'package:twitter/services/authentication.dart';
import 'package:twitter/services/aws_api.dart';
import 'package:twitter/services/aws_auth.dart';
import 'package:twitter/util/router.dart';
import 'package:twitter/vms/auth_vm.dart';

void main() {
  db.initDummyData();
  runApp(TwitterClone());
}

class TwitterClone extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Api>(
          builder: (_) => AWSTwitterApi.getInstance(),
        ),
        ChangeNotifierProvider<AuthenticationService>(
          builder: (_) => AWSAuthenticationService(),
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
