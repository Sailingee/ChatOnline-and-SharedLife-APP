import 'package:danc/posts_page.dart';
import 'package:flutter/material.dart';
import 'item/home_item_page.dart';


class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //顶部可滑动AppBar
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool flag) {
            return [
              SliverAppBar(
                backgroundColor: Colors.orange,
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
                title: Text('Shared Moments'),
                centerTitle: true,
              )
            ];
          },
          body: HomeItemPage()
        ));
  }
}
