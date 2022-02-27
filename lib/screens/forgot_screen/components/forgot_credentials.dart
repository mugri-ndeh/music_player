import 'package:Excite/screens/forgot_screen/Controller/controller.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';

class ForgotCredentials extends StatelessWidget {
  const ForgotCredentials({Key? key}) : super(key: key);

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
            Text(
              'Forgot Your Password?',
              style: TextStyle(
                  fontSize: 35, color: white, fontWeight: FontWeight.bold),
            ),
            Text(
              "Don't worry we got you.",
              style: TextStyle(
                fontSize: 20,
                color: white.withOpacity(0.6),
                fontWeight: FontWeight.w800,
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
                    child: Form(
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        style: TextStyle(color: white),
                        keyboardType: TextInputType.emailAddress,
                        controller: ForgotController.emailcontroller,
                        decoration: InputDecoration(
                            hintText: 'Please Enter Your Email Address',
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
            )
          ],
        ),
      ),
    );
  }
}
