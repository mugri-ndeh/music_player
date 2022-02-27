import 'package:Excite/screens/home_screen/pages/_new_home_page.dart';
import 'package:Excite/screens/home_screen/widgets/exit-popup.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
                NewHomePage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
