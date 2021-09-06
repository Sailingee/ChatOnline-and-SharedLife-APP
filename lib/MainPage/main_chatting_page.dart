import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/chat_search.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'item/chat_room.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({Key? key}) : super(key: key);

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  bool isSearching = false;

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

  @override
  Widget build(BuildContext context) {
    if(Me.me==null)
      return noneLoginPage();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('聊天'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchChatPage()));
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Column(
        children: [
          chatRoomsList(),
        ],
      ),
    );
  }

  Stream<QuerySnapshot>? chatRooms = null;

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    FutureData.getUserChats(Me.me!.IDnumber).then((snap) {
      setState(() {
        chatRooms = snap;
        print("we got the data + ${chatRooms.toString()}");
      });

      print(snap);
      print(chatRooms.toString());
    }).catchError((error) {
      print('chatRooms errors at $error');
    });
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (chatRooms == null) return Text('chat Rooms is null');
        if (snap.hasError) return Text('snap has Error');
        if (snap.hasData && snap.data == null) return Text('snap data null');
        if (snap.hasData == true) {
          return ListView.builder(
              itemCount: snap.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String ID = snap.data!.docs[index]["id"];
                if (cache.containsKey(ID)) {
                  return ChatRoomsTile.cache(
                    cache[ID]!.cachename,
                    cache[ID]!.cacheImage,
                    IDnumber: cache[ID]!.IDnumber,
                    ID: cache[ID]!.ID,
                    isRead: snap.data!.docs[index][Me.me!.IDnumber],
                    firstLoad: false,
                  );
                } else {
                  cache[ID] = ChatRoomsTile(
                    IDnumber: snap.data!.docs[index]['id']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Me.me!.IDnumber, ""),
                    ID: ID,
                    isRead: snap.data!.docs[index][Me.me!.IDnumber],
                  );
                  cache[ID]!.firstLoad = true;
                  return cache[ID] as StatelessWidget;
                }
              });
        }
        if (snap.connectionState == ConnectionState.done) return Text('done');
        return Text('loading');
      },
    );
  }

  Map<String, ChatRoomsTile> cache = new Map();
}

class ChatRoomsTile extends StatelessWidget {
  final String? IDnumber; //对方的IDnumber
  final String? ID; //双方ID
  bool? isRead;

  bool? firstLoad;
  late NetworkImage cacheImage;
  late String cachename;

  //双方的ID信息，还需要通过 异步网络请求 头像 名字等信息
  ChatRoomsTile(
      {@required this.IDnumber,
      @required this.ID,
      @required this.isRead,
      this.firstLoad = true});

  //cache模式下不用再调用异步方法
  ChatRoomsTile.cache(this.cachename, this.cacheImage,
      {@required this.IDnumber,
      @required this.ID,
      @required this.isRead,
      this.firstLoad = false});






  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Room(
                      ID: ID!,
                      cacheName: cachename,
                    )));
      },
      child: Container(
        color: Colors.orange[100],
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            // 头像
            Container(
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30)),
                child: firstLoad == true
                    ? FutureBuilder(
                        future: futureHeadImage(),
                        builder: (context, snopshots) {
                          if (snopshots.hasError) return Text('has Error');

                          if (snopshots.hasData &&
                              snopshots.connectionState ==
                                  ConnectionState.done) {
                            cacheImage = NetworkImage(snopshots.data as String);

                            return CircleAvatar(
                              radius: 36.0,
                              backgroundImage:
                                  NetworkImage(snopshots.data as String),
                            );
                          }

                          return Text(IDnumber!.substring(0, 1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontFamily: 'OverpassRegular',
                                  fontWeight: FontWeight.w300));
                        },
                      )
                    : CircleAvatar(radius: 36.0, backgroundImage: cacheImage)),
            SizedBox(
              width: 12,
            ),
            // ID/名字
            firstLoad == true
                ? FutureBuilder(
                    future: futureGetName(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        {
                          cachename = snapshot.data as String;
                          return Text(snapshot.data as String,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'OverpassRegular',
                                  fontWeight: FontWeight.w300));
                        }
                      }
                      return Text(IDnumber!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300));
                    })
                : Text(cachename,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
            Expanded(
              child: Container(
                  alignment: Alignment.centerRight,
                  child: isRead == false
                      ? Icon(
                          Icons.notifications,
                          color: Colors.red,
                        )
                      : null),
            )
          ],
        ),
      ),
    );
  }



  futureGetName() async {
    var doc = await FutureData.getUserDoc(IDnumber!).catchError((error) {
      print(error);
    });
    return doc['name'];
  }

  futureHeadImage() async {
    var doc = await FutureData.getUserDoc(IDnumber!).catchError((error) {
      print(error);
    });
    print("headImage ${doc['headImage']}");
    return await FutureData.getHeadImage(doc['headImage']);
  }
}
