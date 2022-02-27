import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/forgot_screen/components/background_design.dart';
import 'package:Excite/screens/forgot_screen/components/bottom_container.dart';
import 'package:Excite/screens/forgot_screen/components/forgot_credentials.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({Key? key}) : super(key: key);

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
              ForgotCredentials(),
              BottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
