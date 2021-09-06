import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/sign_up_page.dart';
import 'package:danc/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    userName = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  Me? me;
  late TextEditingController userName;
  late TextEditingController password;
  CollectionReference? ref;
  CollectionReference ConnectionToDataBase() {
    return FirebaseFirestore.instance.collection('users');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Container(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                        0.0,
                        1.0
                      ],
                      colors: [
                        Color.fromRGBO(0xf1, 0x96, 0x0c, 0x55),
                        Color.fromRGBO(0xe8, 0x68, 0x68, 0x55)
                      ])),
            ),
            Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/login_logo.png'),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 45),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.black54,
                            size: 30,
                          ),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              maxLines: 1,
                              controller: userName,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white70),
                                  hintText: '  user name',
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin:
                      EdgeInsets.only(left: 20, right: 45, top: 20, bottom: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.vpn_key,
                            color: Colors.black54,
                            size: 30,
                          ),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              obscureText: true,
                              maxLines: 1,
                              controller: password,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white70),
                                  hintText: '  password',
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (contex) {
                                return AlertDialog(
                                  title: Center(child: Text('正在验证')),
                                  contentPadding: EdgeInsets.fromLTRB(123, 0, 123, 0),
                                  content: CircularProgressIndicator(),
                                );
                              });

                          if (ref == null) ref = ConnectionToDataBase();
                          FutureData.authorization(userName,password).then((isCorrect) {
                            if (isCorrect == true) {
                              Navigator.of(context).pop();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                      (route) => false);
                              Fluttertoast.showToast(
                                  msg: '登陆成功', toastLength: Toast.LENGTH_LONG);
                            } else {
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                  msg: '账号或密码错误', toastLength: Toast.LENGTH_LONG);
                            }
                          });
                        },
                        child: Text("Login"),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.orange)),
                      ),
                    ),
                    Container(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>SignUpPage()));
                        },
                        child: Text("Sign Up"),
                        style: ButtonStyle(
                          foregroundColor:
                          MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.white;
                            return Colors.black54;
                          }),
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),),
      )
    ));
  }
}
