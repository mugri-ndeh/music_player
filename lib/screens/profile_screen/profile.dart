import 'dart:async';
import 'dart:convert';

import 'package:Excite/constants/constants.dart';
import 'package:Excite/screens/login_screen/login_screen.dart';
import 'package:Excite/server/api/api.dart';
import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

var name;
var email;
var id;
bool isDone = true;

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pref) => {
          setState(() {
            id = pref.getString("id");
            name = pref.getString("name");
            email = pref.getString("email");
          })
        });
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isAnimating = true;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            iconSize: 16,
            padding: EdgeInsets.symmetric(horizontal: 24),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          )
        ],
        backgroundColor: black,
      ),
      backgroundColor: black,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(appPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello ${name}",
                        style: TextStyle(
                          fontSize: 35,
                          color: white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: appPadding),
                        child: Container(
                          child: ClayContainer(
                            color: black,
                            borderRadius: 30,
                            depth: -30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: appPadding),
                              child: TextFormField(
                                controller: _nameController,
                                style: TextStyle(color: white),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    hintText: name,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: appPadding),
                            child: Form(
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                style: TextStyle(color: white),
                                decoration: InputDecoration(
                                    hintText: email,
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
                        padding:
                            const EdgeInsets.symmetric(vertical: appPadding),
                        child: Container(
                          child: ClayContainer(
                            color: black,
                            borderRadius: 30,
                            depth: -30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: appPadding),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _passwordController,
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
              ),
              Positioned(
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
                            onEnd: () =>
                                setState(() => isAnimating = !isAnimating),
                            child: buildButton(),
                          ),
                        ),
                      ],
                    ),
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
              'Update',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 17, color: black),
            ),
          ),
        ),
      ),
      onTap: () async {
        if (await updateProfile(
          id,
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        )) {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            backgroundColor: black,
            confirmBtnColor: white,
            text: "Your Profile Updated Successfully",
          );
        }
      },
    );
  }

  updateProfile(String id, String name, String email, String password) async {
    if (isDone) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        backgroundColor: black,
        text: "Loading",
      );
    }

    Response response = await post(Uri.parse(Api.profileupdate_api), body: {
      "id": id,
      "name": name,
      "password": password,
    });
    var data = jsonDecode(response.body);
    if (data['success'] == "1") {
      setState(() {
        isDone = false;
        Navigator.of(context, rootNavigator: true).pop();
      });
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (name.isNotEmpty) {
        pref.setString("name", _nameController.text.toString());
      }
      if (email.isNotEmpty) {
        pref.setString("email", email);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['msg'])));
    }
    return true;
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
