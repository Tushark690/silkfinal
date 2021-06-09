import 'dart:convert';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {



  Color _gradientTop = Color(0xFF039be6);
  Color _gradientBottom = Color(0xFF0299e2);
  Color _mainColor = Color(0xFF0181cc);
  Color _underlineColor = Color(0xFFCCCCCC);
  TextEditingController _mobile;
  TextEditingController _password;
  GlobalKey<FormState> _formKey= GlobalKey();
  List<DropdownMenuItem> _courses=[];
  int _courseValue =0;

  @override
  void initState() {
    _mobile=TextEditingController();
    _password=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            // top blue background gradient
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_gradientTop, _gradientBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
            ),
            // set your logo here
            Container(
                margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 20, 0, 0),
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/logo_dark.png', height: 120)),
            ListView(
              children: <Widget>[
                // create form login
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.fromLTRB(32, MediaQuery.of(context).size.height / 3.5 - 72, 32, 0),
                  color: Colors.white,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Center(
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                    color: _mainColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            TextFormField(
                              controller: _mobile,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[600])),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _underlineColor),
                                ),
                                labelText: 'Mobile',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                              ),
                              validator: (val){
                                if(val.trim().length<1){
                                  return "Please enter mobile";
                                }else if(val.trim().length!=10){
                                  return "Mobile number must be 10 digits";
                                }

                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _password,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              obscureText: true,
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey[600])),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: _underlineColor),
                                  ),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.grey[700])),
                              validator: (val){
                                if(val.trim().length<1){
                                  return "Please enter password";
                                }

                                return null;
                              },
                            ),


                            SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: double.maxFinite,
                              child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                          (Set<MaterialState> states) => _mainColor,
                                    ),
                                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        )
                                    ),
                                  ),
                                  onPressed: () {
                                    if(_formKey.currentState.validate()){
                                      FirebaseFirestore.instance.collection("login").get().then((QuerySnapshot snapshot) {
                                        snapshot.docs.forEach((f) async{
                                          _signUpToast(f.get("mobile"));
                                          _signUpToast(f.get("password"));
                                          if(f.get("mobile")!=_mobile.text){
                                            _signUpToast("Account not found");
                                          }else if(f.get("mobile")!=_mobile.text && f.get("password")!=_password.text){
                                            _signUpToast("Wrong Password");
                                          }else if(f.get("mobile")==_mobile.text && f.get("password")==_password.text){
                                            _signUpToast("Log in successful");
                                            // SharedPreferences sp = await SharedPreferences.getInstance();
                                            // sp.setString("login", "true");
                                            // sp.setString("loginDate", DateTime.now().toString());
                                            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),), (route) => false);
                                          }else{
                                            _signUpToast("Error. Please try again");
                                          }
                                        });
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      'SIGNUP',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
                SizedBox(
                  height: 50,
                ),
                // create sign up link
                Center(
                  child: Wrap(
                    children: <Widget>[
                      Text('Already a user? '),
                      GestureDetector(
                        onTap: () {
                          Fluttertoast.showToast(msg: 'Click sign-in', toastLength: Toast.LENGTH_SHORT);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              color: _mainColor,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          ],
        )
    );
  }



  void _signUpToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 18.0);
  }
}
