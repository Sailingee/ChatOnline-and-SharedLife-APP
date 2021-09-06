import 'package:danc/Logic/FutureData.dart';
import 'package:danc/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

main()=>runApp(Start());
class Start extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: SignUpPage(),
   );
  }

}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController userName = new TextEditingController();
  TextEditingController IDnumber = new TextEditingController();
   TextEditingController password = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(

        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                            Icons.phone,
                            color: Colors.black54,
                            size: 30,
                          ),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              maxLines: 1,
                              controller: IDnumber,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white70),
                                  hintText: 'PhoneNumber',
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin:
                      EdgeInsets.only(left: 20, right: 45, top: 20, bottom: 0),
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
                              obscureText: false,
                              maxLines: 1,
                              controller: userName,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white70),
                                  hintText: ' Name',
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
                                  hintText: ' password',
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          
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
                          UserRequired.signUpAuthorization(IDnumber.text, userName.text, password.text).then((result){
                            if(result==true)
                              Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>HomePage()) , (route) => false);
                            else{
                              Navigator.pop(context);
                              Fluttertoast.showToast(msg: "验证失败",toastLength: Toast.LENGTH_LONG);
                            }
                          });
                          
                        },
                        child: Text("Sign Up"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
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
        ),)


      )
    );
  }
}
