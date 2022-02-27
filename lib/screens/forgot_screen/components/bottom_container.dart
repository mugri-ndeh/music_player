import 'dart:convert';

import 'package:Excite/screens/forgot_screen/Controller/controller.dart';
import 'package:Excite/screens/login_screen/login_screen.dart';
import 'package:Excite/server/api/api.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:Excite/constants/constants.dart';

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
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    "Have You Done? Login",
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
                'Change Password',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 17, color: black),
              ),
            ),
          ),
        ),
        onTap: () async {
          setState(() => state = ButtonState.loading);
          forgotPass(ForgotController.emailcontroller.text.toString());
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

  forgotPass(String email) async {
    try {
      if (email.isNotEmpty) {
        Response response = await post(Uri.parse(Api.forgot_api), body: {
          "email": email,
        });
        var data = jsonDecode(response.body);

        if (data['success'] == "1") {
          setState(() => state = ButtonState.done);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['msg'])));
          setState(() => state = ButtonState.init);
        } else {
          await Future.delayed(Duration(seconds: 3));
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
