import 'dart:collection';

import 'package:ecommerce_app/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../services/userService.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  double borderWidth = 1.0;
  final _signUpFormKey = GlobalKey<FormState>();
  HashMap userValues = HashMap<String, String>();
  Map customeWidth = Map<String, double>();
  double? fieldPadding;

  UserService userService = UserService();

  setBorder(double width, Color color) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(36.0),
        borderSide: BorderSide(width: width, color: color));
  }

  signUpUser() async {
    bool internetConnection = await InternetConnectionChecker().hasConnection;
    if (this._signUpFormKey.currentState!.validate()) {
      if (internetConnection) {
        await userService.signUp(userValues);
        int? statusCode = userService.statusCode;
        if (statusCode == 400) {
          return SnackBar(content: Text("${userService.msg}"));
        }
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      print("Trying to connect");
    }
  }

  InputDecoration customeFormField(String text) {
    return InputDecoration(
        hintText: text,
        labelText: text,
        prefixIcon: setFormIcons(text),
        contentPadding: EdgeInsets.all(customeWidth['fieldPadding']),
        errorBorder: this.setBorder(1.8, Colors.red),
        focusedErrorBorder: this.setBorder(1.2, Colors.red),
        focusedBorder: this.setBorder(2.0, Colors.blue),
        enabledBorder: this.setBorder(1.0, Colors.white),
        fillColor: Colors.white,
        filled: true,
        errorStyle: TextStyle(fontSize: sizeConfig.safeBlockHorizontal! * 3));
  }

  Icon setFormIcons(String label) {
    Icon? icon;
    switch (label) {
      case 'Full name':
        {
          icon = const Icon(Icons.person);
        }
      case 'Email':
        {
          icon = const Icon(Icons.email);
        }
      case 'Mobile number':
        {
          icon = const Icon(Icons.call);
        }
      case 'password':
        {
          icon = const Icon(Icons.lock);
        }
    }
    return icon!;
  }

  setUpFieldPadding(screen) {
    switch (screen) {
      case 'smallMobile':
        {
          customeWidth['fieldPadding'] = 10.00;
          customeWidth['formFieldSpacing'] =
              sizeConfig.safeBlockVertical! * 2.4;
          customeWidth['fieldPadding'] = sizeConfig.safeBlockVertical! * 2.6;
          break;
        }
      case 'largeMobile':
        {
          customeWidth['fieldPadding'] = 20.00;
          customeWidth['formFieldSpacing'] =
              sizeConfig.safeBlockVertical! * 2.6;
          customeWidth['fieldPadding'] = sizeConfig.safeBlockVertical! * 2.2;
          break;
        }
      case 'tablet':
        {
          customeWidth['fieldPadding'] = 26.00;
          customeWidth['formFieldSpacing'] = sizeConfig.safeBlockVertical! * 5;
          customeWidth['fieldPadding'] = sizeConfig.safeBlockVertical! * 2.4;
          break;
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    setUpFieldPadding(sizeConfig.screenSize);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context, false);
            }),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: sizeConfig.safeBlockVertical! / 2,
                horizontal: sizeConfig.safeBlockHorizontal! * 10),
            child: Form(
                key: _signUpFormKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Lets Get Started",
                      style: TextStyle(
                        fontSize: sizeConfig.safeBlockHorizontal! * 8.0,
                      ),
                    ),
                    Text(
                      "Create an account to get all features",
                      style: TextStyle(
                        fontSize: sizeConfig.safeBlockHorizontal! * 3.8,
                        color: Colors.grey[800],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: sizeConfig.safeAreaVertical! * 0.8),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: this.customeFormField("Full name"),
                            onSaved: (String? val) {
                              userValues['fullName'] = val;
                            },
                          ),
                          SizedBox(
                            height: customeWidth['formFieldSpacing'],
                          ),
                          TextFormField(
                            decoration: this.customeFormField("Mobile number"),
                            keyboardType: TextInputType.phone,
                            onSaved: (String? val) {
                              userValues['mobileNumber'] = val;
                            },
                            style: TextStyle(
                                fontSize: customeWidth['fieldTextSize']),
                          ),
                          SizedBox(
                            height: customeWidth['formFieldSpacing'],
                          ),
                          TextFormField(
                            decoration: this.customeFormField("Email"),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? val) {
                              userValues['email'] = val;
                            },
                            style: TextStyle(
                                fontSize: customeWidth['fieldTextSize']),
                          ),
                          SizedBox(
                            height: customeWidth['formFieldSpacing'],
                          ),
                          TextFormField(
                            decoration: this.customeFormField("password"),
                            obscureText: true,
                            onSaved: (String? val) {
                              userValues['password'] = val;
                            },
                            style: TextStyle(
                                fontSize: customeWidth['fieldTextSize']),
                          ),
                          SizedBox(
                            height: customeWidth['formFieldSpacing'],
                          ),
                        ],
                      ),
                    )
                  ],
                ))),
      ),
    );
  }
}
