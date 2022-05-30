import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/Login.dart';
import 'package:danc/MainPage/item/MyCollections_page.dart';
import 'package:danc/MainPage/item/MyFollows.dart';
import 'package:danc/MainPage/item/information_page.dart';
import 'package:danc/index_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item/my_posts_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<SettingsList>? informationList;

  @override
  void initState() {
    setSettingsListArray();
    super.initState();
  }

  void setSettingsListArray() {
    informationList = <SettingsList>[
      SettingsList(
        index: SettingsIndex.MyPosts,
        labelName: '我的上传',
        icon: Icon(Icons.photo_camera_back),
      ),
      SettingsList(
        index: SettingsIndex.MyCollections,
        labelName: '我的收藏',
        icon: Icon(Icons.collections)
      ),
      SettingsList(
        index: SettingsIndex.Follows,
        labelName: '我的关注',
        icon: Icon(Icons.nature_people_rounded)
      ),
      SettingsList(
        index: SettingsIndex.Information,
        labelName: '修改个人信息',
        icon: Icon(Icons.person),
      ),
      SettingsList(
        index: SettingsIndex.About,
        labelName: '关于',
        icon: Icon(Icons.info),
      ),
    ];
  }

  //尚未登陆的页面
  Widget noneLoginPage() {
    return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("尚未登陆"),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage()));
                },
                child: Text("Login"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange)
                ),
              )
            ],
          ),
    );
  }

  Me? me;
  @override
  Widget build(BuildContext context) {
    if (Me.me == null) {
      return noneLoginPage();
    } else {
      me = Me.getInstance();
    }
    return FutureBuilder(
      future: me!.getHeadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return setting_widget();
        return Container();
      },
    );
  }


  //登陆后的页面
  Widget setting_widget() {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          item_HeadImage(),
          const SizedBox(
            height: 4,
          ),
           Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
              item_settings(),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          item_LoginOut()
        ]));
  }

  //头像
  Widget item_HeadImage(){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: const Offset(2.0, 4.0),
                      blurRadius: 8),
                ],
              ),
              child: me == null
                  ? ClipRRect(
                borderRadius:
                const BorderRadius.all(Radius.circular(60.0)),
                child: Image.asset('assets/images/userImage.png'),
              )
                  : CircleAvatar(
                radius: 36.0,
                backgroundImage: NetworkImage(
                  me!.head_picture,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                me == null ? 'Chris Hemsworth' : me!.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //设置选项菜单
  Widget item_settings(){
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0.0),
        itemCount: informationList?.length,
        itemBuilder: (BuildContext context, int index) {
          return inkwell(informationList![index]);
        },
      ),
    );
  }

  //底部登出栏
  Widget item_LoginOut(){
    return Column(
      children: <Widget>[
        me != null
            ? ListTile(
          title: Text(
            '退出登录',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
          trailing: Icon(
            Icons.power_settings_new,
            color: Colors.red,
          ),
          onTap: () {
            setState(() {
              Me.me = null;
              sharedPreCacheCancel();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IndexPage()),
                      (route) => false);
              Fluttertoast.showToast(
                  msg: '已登出', toastLength: Toast.LENGTH_LONG);
            });
          },
        )
            : Container(),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        )
      ],
    );
  }


  Future<void> sharedPreCacheCancel() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("isLogin", false);
  }

  Widget inkwell(SettingsList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
            selectedListData(listData);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName),
                        )
                      : Icon(listData.icon?.icon),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectedListData(SettingsList listData){
    switch(listData.index){
      case SettingsIndex.About:
        Fluttertoast.showToast(msg: "About",toastLength: Toast.LENGTH_SHORT);
        break;
      case SettingsIndex.Information:
        Navigator.push(context,MaterialPageRoute(builder: (context)=>InformationPage()));
        break;
      case SettingsIndex.MyPosts:
        Navigator.push(context,MaterialPageRoute(builder: (context)=>MyPosts()));
        break;
      case SettingsIndex.MyCollections:
        Navigator.push(context,MaterialPageRoute(builder: (context)=>MyCollectionsPage()));
        break;
      case SettingsIndex.Follows:
        Navigator.push(context,MaterialPageRoute(builder: (context)=>MyFollow()));
        break;
      default:
        Fluttertoast.showToast(msg: "Error",toastLength: Toast.LENGTH_LONG);
    }
  }


}

enum SettingsIndex {
  MyPosts,
 // Favorites,
  Information,
 // General,
  Home,
  Help,
  About,
  MyCollections,
  Follows
}

class SettingsList {
  SettingsList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });
  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  SettingsIndex? index;
}
