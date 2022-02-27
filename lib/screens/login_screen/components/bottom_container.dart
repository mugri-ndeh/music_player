import 'dart:convert';

import 'package:Excite/screens/home_screen/home_screen.dart';
import 'package:Excite/screens/login_screen/controller/controllers.dart';
import 'package:Excite/screens/signup_screen/signup_screen.dart';
import 'package:Excite/server/api/api.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:Excite/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ButtonState { init, loading, done }

class BottomContainer extends StatefulWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  State<BottomContainer> createState() => _BottomContainerState();
}

class _BottomContainerState extends State<BottomContainer> {
  ButtonState state = ButtonState.init;
  bool isAnimating = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isStreched = state == ButtonState.init;
    final isDone = state == ButtonState.done;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        child: ClayContainer(
          color: black,
          height: size.height * 0.3,
          depth: 60,
          spread: 20,
          customBorderRadius: BorderRadius.only(
            topRight: Radius.elliptical(350, 250),
            topLeft: Radius.elliptical(350, 250),
          ),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Container(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeIn,
                  onEnd: () => setState(() => isAnimating = !isAnimating),
                  child: isStreched ? buildButton() : buildSmallButton(isDone),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: appPadding),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    "Dont've An Account? SignUp",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        color: white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton() {
    return GestureDetector(
        child: ClayContainer(
          color: white,
          depth: 20,
          borderRadius: 30,
          curveType: CurveType.convex,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: appPadding / 2, horizontal: appPadding * 2),
            child: FittedBox(
              child: Text(
                'Login',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 17, color: black),
              ),
            ),
          ),
        ),
        onTap: () async {
          setState(() => state = ButtonState.loading);
          login(Controllers.emailcontroller.text.toString(),
              Controllers.passwordcontroller.text.toString());
        });
  }

  Widget buildSmallButton(bool isDone) {
    final color = isDone ? Colors.white : Colors.white;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: appPadding / 2, horizontal: appPadding * 2),
        child: isDone
            ? Icon(
                Icons.done,
                size: 30,
                color: Colors.black,
              )
            : SizedBox(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
                height: 30,
                width: 30,
              ),
      ),
    );
  }

  login(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        Response response = await post(Uri.parse(Api.login_api), body: {
          "email": email,
          "password": password,
        });
        var data = jsonDecode(response.body);

        if (data['success'] == "1") {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("name", data['name']);
          await pref.setString("email", data['email']);
          await pref.setString("id", data['id']);

          setState(() => state = ButtonState.done);
          await Future.delayed(Duration(seconds: 1));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          setState(() => state = ButtonState.init);
        } else {
          setState(() => state = ButtonState.init);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['msg'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Make Sure You Entered All The Fields")));
        setState(() => state = ButtonState.init);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
