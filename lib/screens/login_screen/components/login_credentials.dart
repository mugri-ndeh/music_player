import 'package:Excite/screens/login_screen/controller/controllers.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/forgot_screen/forgot_screen.dart';

class LoginCredentials extends StatelessWidget {
  const LoginCredentials({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height * 0.3,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(appPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo/splash_logo.png",
                  height: 30,
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Let's Login.",
                style: TextStyle(
                  fontSize: 30,
                  color: white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: appPadding),
              child: Container(
                child: ClayContainer(
                  color: black,
                  borderRadius: 30,
                  depth: -30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: appPadding),
                    child: TextFormField(
                      controller: Controllers.emailcontroller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: 'Enter Your Email Address',
                          hintStyle: TextStyle(
                            color: white.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          fillColor: white),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: ClayContainer(
                color: black,
                borderRadius: 30,
                depth: -30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: appPadding),
                  child: TextFormField(
                    obscureText: true,
                    controller: Controllers.passwordcontroller,
                    style: TextStyle(color: white),
                    decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        hintStyle: TextStyle(
                          color: white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        fillColor: white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: appPadding / 2),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotScreen()),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontSize: 15,
                      color: white.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
