import 'package:bottom_navy_bar/bottom_navy_bar.dart';
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
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        selectedIndex: currentIndex,
        onItemSelected: (index) {
          setState(() {
            //_pageController.jumpToPage(index);
            currentIndex = index;

          });
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('推送'),
              icon: Icon(Icons.home)
          ),
          BottomNavyBarItem(
              title: Text('联系人'),
              icon: Icon(Icons.people)
          ),
          BottomNavyBarItem(
              title: Text('设置'),
              icon: Icon(Icons.settings)
          ),
        ],
      ),
      body: isLoginPage()
    );
  }
  late PageController _pageController;


  @override
  void initState() {
    _pageController = new PageController();
  } //检查是否有登陆缓存 有过登陆就不需要再刷新页面
  Widget isLoginPage()
  {
    if(Me.me==null && currentIndex!=0 ){
      return PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => currentIndex = index);
        },
        children: <Widget>[
          HomePage(),
          ChattingPage(),
          SettingPage()
        ],
      );
      //return  list[currentIndex];
    }
    return IndexedStack(index: currentIndex,children: list);
    //return Container();
  }


}
