import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/Me.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';

class MyPosts extends StatefulWidget {
  const MyPosts({Key? key}) : super(key: key);

  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: FutureBuilder(
          future: getPostTile(),
          builder: (context, AsyncSnapshot<List<PostsItem>> snapshots) {
            if (snapshots.hasError) return Text("Error");
            if (snapshots.connectionState == ConnectionState.done)
              return ListView.builder(
                  itemCount: snapshots.data!.length,
                  itemBuilder: (context, index) {
                    return PostTile(snapshots.data![index]);
                  });
            return Text("loading");
          },
        ),
      ),
    );
  }

  Widget PostTile(PostsItem item) {
    String time = item.date.toDate().toString();
    time = time.substring(0, time.indexOf(":"));
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShowPotos(item)));
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                time,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Text(item.title,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w300)),
            )
          ],
        ),
      ),
    );
  }

  Future<List<PostsItem>> getPostTile() async {
    List<PostsItem> res = [];

    await FirebaseFirestore.instance
        .collection("messages")
        .where("creatorID", isEqualTo: Me.me!.IDnumber)
        .get()
        .then((docs) async {
      for (var doc in docs.docs) {
        String title = doc['title'];
        String article = doc['article'];
        String document = Me.me!.IDnumber + doc['messageID'].toString();
        Timestamp date = doc['date'];
        List<String> imageList = [];
        for (int i = 0; i < doc['imageLength']; ++i) {
          String path = "uploads/${Me.me!.IDnumber}/${document}/${i}.jpg";
          String url = await getURL(path);
          imageList.add(url);
        }

        res.add(PostsItem(title, article, date, imageList));
      }
      return res;
    });
    return res;
  }

  Future<String> getURL(String path) async {
    return await firebase_storage.FirebaseStorage.instance
        .ref('$path')
        .getDownloadURL();
  }
}

class PostsItem {
  PostsItem(this.title, this.article, this.date, this.imageList);
  String title;
  String article;
  Timestamp date;
  List<String> imageList;
}

class ShowPotos extends StatefulWidget {
  ShowPotos(this.item, {Key? key}) : super(key: key);
  PostsItem item;
  @override
  _ShowPotosState createState() => _ShowPotosState();
}

class _ShowPotosState extends State<ShowPotos> {
  @override
  Widget build(BuildContext context) {
    return showPosts(widget.item);
  }
  bool isfold = false;
  Widget showPosts(PostsItem item) {
    int index = 0;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Swiper(
              itemCount: item.imageList.length,
              index: index,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    //PhotoView 可以让图片拥有手势操作
                    child: PhotoView(
                  imageProvider: NetworkImage(item.imageList[index]),
                ));
              },
              pagination: new SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      color: Colors.black54,
                      activeColor: Colors.white,
                      size: 8)),
            ),
          ),
          isfold == false
              ? Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    decoration:
                        BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    child: Text(
                      item.article,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                )
              : Container(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: IconButton(
                icon: Icon(
                  isfold==false?Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    isfold = !isfold;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
