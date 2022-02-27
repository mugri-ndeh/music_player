import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:Excite/constants/constants.dart';
import '../controller/controllers.dart';

class SignupCredentials extends StatelessWidget {
  const SignupCredentials({Key? key}) : super(key: key);

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
              'Let\'s get started',
              style: TextStyle(
                fontSize: 35,
                color: white,
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
                    child: TextFormField(
                      controller: Controllers.nameController,
                      style: TextStyle(color: white),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'Enter Your Name',
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
                  child: Form(
                    child: TextFormField(
                      controller: Controllers.emailController,
                      style: TextStyle(color: white),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: appPadding),
              child: Container(
                child: ClayContainer(
                  color: black,
                  borderRadius: 30,
                  depth: -30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: appPadding),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: Controllers.passwordController,
                          obscureText: true,
                          style: TextStyle(color: white),
                          decoration: InputDecoration(
                              hintText: 'Enter A Strong Password',
                              hintStyle: TextStyle(
                                color: white.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              fillColor: white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
