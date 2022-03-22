import 'dart:async';
import 'package:Excite/screens/home_screen/api/local_storage.dart';
import 'package:Excite/screens/home_screen/home_screen.dart';
import 'package:Excite/screens/home_screen/notifiers/audio_provider.dart';
import 'package:Excite/screens/home_screen/pages/home_page.dart';
import 'package:Excite/screens/home_screen/pages/testing%20_page.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:Excite/screens/login_screen/login_screen.dart';

var loginData;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  loginData = pref.getString("name");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavouritesHelper()),
        ChangeNotifierProvider(create: (_) => PlaylistHelper()),
        ChangeNotifierProvider(create: (_) => AudioHelper()),
      ],
      child: MaterialApp(
        title: 'Excite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: loginData != null ? HomePage() : LoginScreen(),
      ),
    );
  }
}
