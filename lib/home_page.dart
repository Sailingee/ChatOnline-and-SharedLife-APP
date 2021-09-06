import 'package:danc/MainPage/main_chatting_page.dart';
import 'package:danc/MainPage/main_setting_page.dart';
import 'package:flutter/material.dart';

import 'Logic/Me.dart';
import 'MainPage/main_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> list = [
    MainHomePage(),
    ChattingPage(),
    SettingPage(),
  ];
  List<BottomNavigationBarItem> bottomNavigationBarItem = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_sharp), label: 'Chats'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];
  int currentIndex = 0;

  //底部导航栏以及切换
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavigationBarItem,
        selectedItemColor: Colors.red,
        currentIndex: currentIndex,
        onTap: (int ind) {
          setState(() {
            currentIndex = ind;
          });
        },
      ),
      body: isLoginPage()
    );
  }

  //检查是否有登陆缓存 有过登陆就不需要再刷新页面
  Widget isLoginPage()
  {
    if(Me.me==null && currentIndex!=0 ){
      return  list[currentIndex];
    }
    return IndexedStack(index: currentIndex,children: list);
  }


}
