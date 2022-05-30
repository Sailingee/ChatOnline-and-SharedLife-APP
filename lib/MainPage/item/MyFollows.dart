import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/Follower.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/show_picture_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Message.dart';
import 'MyCollections_page.dart';

class MyFollow extends StatefulWidget {
  const MyFollow({Key? key}) : super(key: key);

  @override
  State<MyFollow> createState() => _MyFollowState();
}

class _MyFollowState extends State<MyFollow> {
  late Me me;
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    me = Me.getInstance();
    _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(me.IDnumber.toString())
        .collection("follows")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("关注"),
        ),
        body: Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("something went wrong");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return ListView(
                  children: snapshot.data!.docs.map((
                      DocumentSnapshot document) {
                    print("here");
                    print(document["follow"]);
                    int start = document["follow"].toString().indexOf("(") + 1;
                    int end = document["follow"].toString().indexOf(")");
                    String doc =
                    document["follow"].toString().substring(start, end);
                    print("doc is " + doc);
                    return FutureBuilder(
                        future: FutureData.getFollower(doc),
                        builder: (context, snap) {
                          if (snap.hasError) return Text("hasError");
                          if (snap.connectionState == ConnectionState.done) {
                            Follower follower = snap.data as Follower;
                            follower.news = document["news"];
                            int start = document["follow"].toString().lastIndexOf("/") + 1;
                            int end = document["follow"].toString().indexOf(")");
                            String path = document["follow"].toString().substring(start, end);
                            return InkWell(
                              onTap: () {
                                print("path is "+path);
                                FirebaseFirestore.instance.collection("users")
                                    .doc(Me.me!.IDnumber).collection("follows")
                                    .doc(path).update({
                                  "news":false
                                });

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyFollow_Show(follower)));
                              },
                              child: Container(
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.all(10),
                                              width: 50,
                                              height: 50,
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    follower.headImage),
                                                radius: 36,
                                              )
                                            //Image.network(follower.headImage),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Text(follower.name)
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        margin: EdgeInsets.all(20),
                                        child: follower.news == true
                                            ? Icon(
                                          Icons.notification_add,
                                          color: Colors.red,
                                        )
                                            : Container(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          if (snap.hasData) {
                            print("data");
                            print(snap.data);
                            return Text("wait");
                          }
                          return Text("Waiting");
                        });
                  }).toList(),
                );
              },
            )),
      ),
    );
  }
}

class MyFollow_Show extends StatefulWidget {
  //const MyFollow_Show({Key? key}) : super(key: key);
  Follower follower;

  MyFollow_Show(this.follower);

  @override
  State<MyFollow_Show> createState() => _MyFollow_ShowState();
}

class _MyFollow_ShowState extends State<MyFollow_Show> {
  late Stream<QuerySnapshot> _stream;
  late TextEditingController commentController;

  @override
  void initState() {
    getFollowSnap().then((snap) {
      setState(() {
        _stream = snap;
      });
    });
    commentController = new TextEditingController();
  }

  Future<void> _onRefresh() async {
    setState(() {
      messageCacheQueue.queue = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: showListMSG(),
      ),
    );
  }

  Widget showListMSG() {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 20,
        color: Colors.red,
        backgroundColor: Colors.white,
        notificationPredicate: defaultScrollNotificationPredicate,
        child: streamListView());
  }

  getFollowSnap() async {
    print("IDnumber is " + widget.follower.IDnumber);
    return FirebaseFirestore.instance
        .collection('messages')
    // .orderBy('date', descending: true)
        .where('creatorID', isEqualTo: widget.follower.IDnumber)
        .snapshots();
  }

  Widget streamListView() {
    return StreamBuilder(
      stream: _stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
        if (snapshots.hasError) return Text("加载时发生错误");
        if (snapshots.hasData) {
          return ListView.builder(
              itemCount: snapshots.data!.docs.length,
              itemBuilder: (context, index) {
                final dc = snapshots.data!.docs[index];
                return FutureBuilder(
                  future: FutureData.getStreamMessage(dc),
                  builder: ((context, AsyncSnapshot<Message>? value) {
                    if (value == null) return Text("null value");
                    if (value.hasError) return Text("hasError");
                    if (value.hasData) {
                      //缓存队列 修改一部分数据库内容不会导致整片页面刷新
                      String ID = value.data!.creatorID! +
                          value.data!.messageID!.toString();
                      if (messageCacheQueue.isContains(ID) == true)
                        return MSG(messageCacheQueue.cacheMessage);
                    }
                    if (value.connectionState == ConnectionState.done) {
                      messageCacheQueue.add(value.data!);
                      return MSG(value.data);
                    }
                    return Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(
                          height: 150,
                        )
                      ],
                    );
                  }),
                );
              });
        }
        return Center(
            child: Container(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget MSG(Message? message_obj) {
    return Container(
      decoration:
      BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                    child: CircleAvatar(
                      radius: 36.0,
                      backgroundImage: NetworkImage(
                        message_obj!.head_picture,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Text(
                    message_obj.name,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      icon: Icon(Icons.more_horiz),
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: "follow",
                            child: Text("关注"),
                          ),
                          const PopupMenuItem(
                            value: "collection",
                            child: Text("收藏"),
                          ),
                        ];
                      },
                      onSelected: (value) {
                        String v1 = message_obj.creatorID!;
                        String v2 = message_obj.messageID.toString();
                        String v3 = v1 + v2;
                        if (value == "follow") {
                          var doc = FirebaseFirestore.instance
                              .collection("users")
                              .doc(v1);
                          FutureData.follow_click(doc);
                          Fluttertoast.showToast(msg: "关注成功");
                        }
                        if (value == "collection") {
                          var doc = FirebaseFirestore.instance
                              .collection("messages")
                              .doc(v3);
                          FutureData.collection_click(doc);
                          Fluttertoast.showToast(msg: "收藏成功");
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 280,
            child: Swiper(
                itemCount: message_obj.imageListUrl.length,
                onIndexChanged: (ind) {
                  currentPicture = ind;
                },
                itemBuilder: (BuildContext context, int index) {
                  //返回的Swiper图片集
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ShowPicturePage(
                                      imageList: message_obj.imageListUrl,
                                      index: currentPicture)));
                    },
                    child: Image.network(
                        message_obj.imageListUrl[index].toString(),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        }),
                  );
                }),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LikeIcon(message_obj),
                        SizedBox(
                          width: 50,
                        ),
                        InkWell(
                          onTap: () {
                            showBottomFuction(message_obj);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "评论..",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w100),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Container(
            /*child: Text(
              widget.tweetData.article,
               textAlign: TextAlign.left,
            ),*/
            child: Wrap(
              children: [
                Text(
                  "#" + message_obj.title + "     ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                _RichText(message_obj.article)
              ],
            ),
            alignment: Alignment.topLeft,
            margin: EdgeInsets.all(5),
          ),
          Divider(
            height: 15,
            color: Colors.grey.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  void showBottomFuction(Message message_obj) {
    showModalBottomSheet(
        context: context,
        builder: (context) => commentItemFunction(message_obj));
  }

  Widget commentItemFunction(Message message_obj) {
    return Container(
      height: 390,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment(0, 0),
                      child: Text(
                        '评论区:',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 10, right: 5, top: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.7,
                            child: TextField(
                              controller: commentController,
                              decoration:
                              InputDecoration(border: OutlineInputBorder()),
                              cursorHeight: 30,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                if (Me.me == null) {
                                  Fluttertoast.showToast(msg: "请先登录");
                                  return;
                                }
                                Me me = Me.getInstance();
                                me
                                    .upLoadComment(message_obj, me.name,
                                    commentController.text)
                                    .then((value) {
                                  commentController.text = '';
                                });
                              },
                              child: Text(
                                '提交评论',
                                style: TextStyle(color: Colors.black),
                              ))
                        ],
                      ))
                ],
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Expanded(
              child: Container(
                child: FutureBuilder(
                  future: message_obj.commonts!.get(),
                  builder: (context, AsyncSnapshot snapshots) {
                    if (snapshots.hasError) return Text("hasError");
                    if (snapshots.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          itemCount: snapshots.data!.docs.length,
                          itemBuilder: (context, index) {
                            String image =
                            snapshots.data!.docs[index]['head_image'];
                            String name = snapshots.data!.docs[index]['name'];
                            String comment = snapshots.data!
                                .docs[index]['comment'];

                            return Container(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(7),
                                            width: 55,
                                            height: 55,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  image),
                                              radius: 36,
                                            ),
                                          ),
                                          Text(
                                            name,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                      flex: 1,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                      child:
                                      Text(comment,
                                          style: TextStyle(fontSize: 16)),
                                      flex: 3,
                                    )
                                  ],
                                ));
                          });
                    }
                    return Text("loading");
                  },
                ),
              ))
        ],
      ),
    );
  }

  bool mIsExpansion = false;

// 最大显示行数
  int mMaxLine = 5;

  //region
  //[_text ] 传入的字符串
  Widget _RichText(String _text) {
    if (IsExpansion(_text)) {
      //是否截断
      if (mIsExpansion) {
        return Column(
          children: <Widget>[
            new Text(
              _text,
              textAlign: TextAlign.left,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FlatButton(
                onPressed: () {
                  _isShowText();
                },
                child: Text("收起"),
                textColor: Colors.grey,
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: <Widget>[
            new Text(
              _text,
              maxLines: 3,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FlatButton(
                onPressed: () {
                  _isShowText();
                },
                child: Text("..全文"),
                textColor: Colors.grey,
              ),
            ),
          ],
        );
      }
    } else {
      return Text(
        _text,
        maxLines: 3,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  bool IsExpansion(String text) {
    TextPainter _textPainter = TextPainter(
        maxLines: 3,
        text: TextSpan(
            text: text, style: TextStyle(fontSize: 16.0, color: Colors.black)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 100, minWidth: 50);
    if (_textPainter.didExceedMaxLines) {
      //判断 文本是否需要截断
      return true;
    } else {
      return false;
    }
  }

  void _isShowText() {
    if (mIsExpansion) {
      //关闭
      setState(() {
        mIsExpansion = false;
      });
    } else {
      //打开
      setState(() {
        mIsExpansion = true;
      });
    }
  }

  int currentPicture = 0;
}
