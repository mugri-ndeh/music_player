import 'package:Excite/screens/signup_screen/components/bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/signup_screen/components/background_design.dart';
import 'package:Excite/screens/signup_screen/components/signup_credentials.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: black,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              BackgroundDesign(),
              SignupCredentials(),
              BottomContainer()
            ],
          ),
        ),
      ),
    );
  }
}
