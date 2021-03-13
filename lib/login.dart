import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isRegister = false;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool isValid = false;

  Future handleLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: username.text, password: password.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return e;
    }
  }

  Future handleCreateUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: username.text, password: password.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isRegister ? "Create user" : "Login"),
      ),
      child: Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          setState(() {
            isValid = _formkey.currentState.validate();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              //username
              CupertinoTextFormFieldRow(
                controller: username,
                validator: (val) {
                  if (val.isEmpty) {
                    return "Username is required";
                  } else if (val.isNotEmpty && val.length < 3) {
                    return "Username is greater than 3 ";
                  }
                  return null;
                },
                placeholder: 'Username',
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(
                height: 20,
              ),
              //psw
              CupertinoTextFormFieldRow(
                validator: (val) {
                  if (val.isEmpty) {
                    return "Password is required";
                  } else if (val.isNotEmpty && val.length < 6) {
                    return "Password must be > 5";
                  } else if (val.isNotEmpty && isRegister) {
                    return val != confirmPassword.text
                        ? "Password not match"
                        : null;
                  }
                  return null;
                },
                controller: password,
                placeholder: 'Password',
                obscureText: true,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
              ),

              SizedBox(
                height: 20,
              ),
              //psw confirm
              isRegister
                  ? CupertinoTextFormFieldRow(
                      obscureText: true,
                      controller: confirmPassword,
                      placeholder: 'Confirm password',
                      validator: (val) {
                        if (val.isEmpty) {
                          return "Confirm Password is required";
                        } else if (val.isNotEmpty && isRegister) {
                          return val != password.text
                              ? "Password not match"
                              : null;
                        }
                        return null;
                      },
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10)),
                    )
                  : Container(),
              CupertinoButton(
                  child: Text(isRegister ? "Create now" : "Login now"),
                  onPressed: !isValid
                      ? null
                      : () {
                          if (isRegister) {
                            handleCreateUser()
                                .then((value) => print(value))
                                .catchError((err) => print(err.toString()));
                          } else {
                            handleLogin();
                          }
                        }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isRegister
                      ? "Already have account ?"
                      : "Don't have account ? "),
                  CupertinoButton(
                      child: Text(isRegister ? "Login" : "Create account"),
                      onPressed: () {
                        setState(() {
                          isRegister = !isRegister;
                        });
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
