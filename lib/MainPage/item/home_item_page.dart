import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/CacheQueue.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/show_picture_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Comment.dart';
import 'Message.dart';

MessageCacheQueue messageCacheQueue = new MessageCacheQueue();

class HomeItemPage extends StatefulWidget {
  HomeItemPage();

  @override
  _HomeItemPageState createState() => _HomeItemPageState();
}

class _HomeItemPageState extends State<HomeItemPage> {
  late TextEditingController commentController;
  ScrollController? controller;

  @override
  void initState() {
    initiaStream();
    controller = new ScrollController();
    commentController = new TextEditingController();
    super.initState();
  }

  Widget streamListView() {
    return StreamBuilder(
      stream: stream,
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

  Future<void> _onRefresh() async {
    setState(() {
      messageCacheQueue.queue = [];
    });
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

  late Stream<QuerySnapshot>? stream = null;

  void initiaStream() {
    FutureData.getMessageSnap().then((snap) {
      setState(() {
        stream = snap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //CollectionReference<Map<String, dynamic>>(user)

    return showListMSG();
  }

  Widget MSG(Message? message_obj) {
    int currentPicture = 0;
    return Container(
        margin: EdgeInsets.all(10),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 280,
                child: Swiper(
                  itemCount: message_obj!.imageListUrl.length,
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
                                builder: (context) => ShowPicturePage(
                                    imageList: message_obj.imageListUrl,
                                    index: currentPicture)));
                      },
                      child: Image.network(message_obj.imageListUrl[index],
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
                  },
                  pagination: new SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                          color: Colors.black54,
                          activeColor: Colors.white,
                          size: 8)),
                ),
              ),

              /*头像 名字 标题 内容*/
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60.0)),
                          // child: Image.network(
                          //     message_obj.head_picture), //需要修改为netWork
                          child: CircleAvatar(
                            radius: 36.0,
                            backgroundImage: NetworkImage(
                              message_obj.head_picture,
                            ),
                          ),
                        )),
                    Text(
                      message_obj.name,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    )
                  ],
                ),
                title: Text(
                  message_obj.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  message_obj.article,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                ),
              ),
              Divider(
                height: 15,
                color: Colors.grey.withOpacity(0.6),
              ),

              /*喜欢 评论*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  LikeIcon(message_obj),
                  InkWell(
                    onTap: () {
                      showBottomFuction(message_obj);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mode_comment_outlined),
                      ],
                    ),
                  ),
                  SizedBox(),
                ],
              ),
              SizedBox(
                height: 5,
              )
            ],
          ),
        ));
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
                            width: MediaQuery.of(context).size.width * 0.7,
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
              builder: (context,AsyncSnapshot snapshots) {
                if(snapshots.hasError)
                  return Text("hasError");
                if(snapshots.connectionState == ConnectionState.done)
                  {

                    return ListView.builder(
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context,index){
                          String image = snapshots.data!.docs[index]['head_image'];
                          String name = snapshots.data!.docs[index]['name'];
                          String comment = snapshots.data!.docs[index]['comment'];

                          return Container(
                            child:Row(
                              children: [
                                SizedBox(width: 20,),
                                Flexible(child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(margin: EdgeInsets.all(7),width: 55,height: 55,child: CircleAvatar(backgroundImage: NetworkImage(image),radius: 36,),),
                                    Text(name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),)
                                  ],
                                ),flex: 1,),
                                SizedBox(width: 20,),
                                Flexible(child: Text(comment,style: TextStyle(fontSize: 16)),flex: 3,)
                              ],
                            )
                          );
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

  Widget buildCommentItemWidget(Comment co) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    co.name + " :",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Text(
                      co.comment,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  void showBottomFuction(Message message_obj) {
    showModalBottomSheet(
        context: context,
        builder: (context) => commentItemFunction(message_obj));
  }
}

class LikeIcon extends StatefulWidget {
  LikeIcon(this.message_obj, {Key? key}) : super(key: key);
  Message message_obj;
  @override
  _LikeIconState createState() => _LikeIconState(this.message_obj);
}

class _LikeIconState extends State<LikeIcon> {
  _LikeIconState(this.message_obj);
  Message message_obj;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //click like
        if (Me.me != null) {
          setState(() {
            if (message_obj.isLike == false && Me.me != null) {
              message_obj.isLike = !message_obj.isLike;
              message_obj.likes[Me.me!.IDnumber.toString()] = true;
            } else if (message_obj.isLike == true && Me.me != null) {
              message_obj.isLike = !message_obj.isLike;
              message_obj.likes.remove(Me.me!.IDnumber.toString());
            }
            Me.me!.upLoadLike(message_obj, message_obj.likes);
          });
        }
      },
      child: Row(
        key: ObjectKey(message_obj),
        mainAxisSize: MainAxisSize.min,
        children: [
          message_obj.isLike == false
              ? Icon(Icons.mood)
              : Icon(
                  Icons.mood,
                  color: Colors.orange,
                ),
          Text((message_obj.likes.length).toString())
        ],
      ),
    );
  }
}
