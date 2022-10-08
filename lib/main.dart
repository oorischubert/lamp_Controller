import 'package:flutter/material.dart';
import 'package:led_controller/homepage.dart';
import 'package:led_controller/usersettings.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSettings.init(); //getting user settings when app Boots up!
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: Consumer(builder: (context, UserProvider notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner:
                false, //removes annoying debug banner in debug mode
            title: 'Flutter Demo',
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            home: HomePage(),
          );
        }));
  }
}
