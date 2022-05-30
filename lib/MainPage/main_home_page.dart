import 'package:danc/MainPage/item/home_ite_search.dart';
import 'package:danc/MainPage/item/home_item_page2.dart';
import 'package:danc/posts_page.dart';
import 'package:flutter/material.dart';
import 'item/home_item_page.dart';


class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with SingleTickerProviderStateMixin{
  late TabController tabController;
  late TextEditingController textEditingController;
  @override
  void initState() {
    textEditingController = new TextEditingController();
    tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //顶部可滑动AppBar
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool flag) {
            return [
              SliverAppBar(
                backgroundColor: Colors.cyan,
                pinned: true,
                floating: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PostsPage()));
                    },
                  )
                ],
                title: Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).padding.top * 0.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(17)),
                      color: Colors.white),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                    child: TextField(
                      controller: textEditingController,
                      onEditingComplete: (){
                        setState(() {
                          
                        });
                        //Navigator.push(context,MaterialPageRoute(builder: (context)=>HomeItemSearchPage(textEditingController.text.toString())));
                      },
                      decoration: InputDecoration.collapsed(hintText: "搜索"),
                    ),
                  ),
                ),
                centerTitle: true,
                bottom: TabBar(
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      child: Text("推送"),
                    ),
                    Tab(
                      child: Text("热点"),
                    )
                  ],
                ),
              )
            ];
          },
          body:
              textEditingController.text.length == 0?
            TabBarView(
              controller: tabController,
              children: [
                HomeItemPage(),
                HomeItemPage2()
              ],
            ):
                  HomeItemSearchPage(textEditingController.text.toString())

          //HomeItemPage()
        ));
  }
}
