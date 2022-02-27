import 'package:Excite/screens/home_screen/widgets/exit-popup.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/login_screen/components/background_design.dart';
import 'package:Excite/screens/login_screen/components/bottom_container.dart';
import 'package:Excite/screens/login_screen/components/login_credentials.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        backgroundColor: black,
        body: SingleChildScrollView(
          child: Container(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                BackgroundDesign(),
                LoginCredentials(),
                BottomContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
