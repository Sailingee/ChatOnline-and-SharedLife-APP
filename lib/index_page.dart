import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/MainPage/main_chatting_page.dart';
import 'package:danc/MainPage/main_home_page.dart';
import 'package:danc/guid_page.dart';
import 'package:danc/tweens/fading_four.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Logic/Me.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late TimerUtil mTimer;
  double mTick = 5.0;
  int INDEX_COUNT = 0; //事件计数器,只有事件计数器满足要求才会进入到下一个页面

  /*Firebase初始化*/
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      INDEX_COUNT += 1;
      readCacheData();
    });

    //倒计时对象 时间间隔 和总时间都是毫秒 18毫秒是30帧
    mTimer = new TimerUtil(mInterval: 18, mTotalTime: 5000);
    mTimer.setOnTimerTickCallback((millisUntilFinished) {
      setState(() {
        mTick = millisUntilFinished / 1000;
        if (mTick == 0 && INDEX_COUNT == 2) {
          //如果计时结束,网络状态良好,，那么路由到主页面
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false);
        }
        else if(mTick == 0 && INDEX_COUNT < 2){
          Fluttertoast.showToast(msg: "网络连接失败,退出程序",toastLength: Toast.LENGTH_LONG);
          SystemNavigator.pop();//退出程序
        }

      });
    });
    mTimer.startCountDown();
  }

  //读取存储中的缓存数据 ，例如用户的登陆状态 是否第一次登陆
  void readCacheData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isFirstStart = sharedPreferences.getBool("isFirstStart");
    bool? isLogin = sharedPreferences.getBool("isLogin");
    if (isLogin == true) {
      final IDnumber = sharedPreferences.getString("IDnumber");
      final password = sharedPreferences.getString("password");
      final name = sharedPreferences.getString("name");
      final headImage = sharedPreferences.getString("headImage");
      final docId = sharedPreferences.getInt("docId");
      Me me = Me.getInstance();
      me.initia(IDnumber!, name!, password!, headImage!, docId!);
    }
    if (isFirstStart == null || isFirstStart == true) {
      sharedPreferences.setBool("isFirstStart", false);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GuidPage()),
          (route) => false);
      //如果是第一次使用APP,那么进入引导页面
    }
    //检查是否能使用Firebase
    FirebaseFirestore.instance.collection("Internet").doc("1").get().then((value){
      if(value["1"]=="1")
        INDEX_COUNT++;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        //加载页面的图片
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            'assets/images/3.0/yindao1.jpeg',
            fit: BoxFit.fill,
          ),
        ),

        //底部栏文字
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 300),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Loading...",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    SizedBox(
                      width: 20,
                    ),
                    SpinKitFadingFour(
                      size: 30,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              Text(
                "CopyRight © 2021 XXXX Inc.",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "All rights reserved",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
              //loading information
            ],
          ),
        )
      ],
    ));
  }
}
