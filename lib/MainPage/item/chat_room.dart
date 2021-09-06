import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:danc/Logic/Me.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final bool sendByMe;
  ChatMessage({required this.message, required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8))
                : BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
            color:  sendByMe? Colors.greenAccent :Colors.white,
            ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w400)),
      ),
    );
  }
}

class Room extends StatefulWidget {
  Room({Key? key, required this.ID, required this.cacheName}) : super(key: key);
  String ID;
  String cacheName;
  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  TextEditingController messageEditionController = new TextEditingController();
  bool FIRSTLOAD = true;
  late Stream<QuerySnapshot> stream;
  static ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    stream = FutureData.getRecord(widget.ID);
    FutureData.readAlready(widget.ID, Me.me!.IDnumber);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(widget.cacheName, textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.grey[200],
            child: Stack(
              children: [
                    Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: chatMessage(),
                    ),
                Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 1,
                          color: Colors.black,
                          indent: 3,
                          endIndent: 3,
                        ),
                        Container(
                          color: Colors.grey[100],
                          height: MediaQuery.of(context).size.height * 0.1,
                          padding: EdgeInsets.only(left: 20, right: 10),
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                controller: messageEditionController,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                                decoration: InputDecoration(
                                  hintText: "Input Something",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.grey)),
                                ),
                              )),
                              SizedBox(
                                width: 16,
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                child: ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());

                                    addMessage();
                                  },
                                  child: Text("Send"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  void backIconButtonOnPressed() {
    Navigator.of(context).pop();
  }

  void addMessage() {
    if (messageEditionController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Me.me!.IDnumber,
        "message": messageEditionController.text,
        'time': DateTime.now()
      };
      FutureData.addMessage(widget.ID, chatMessageMap).then((value) {
        FutureData.setUnRead(widget.ID, Me.me!.IDnumber); //设置未读脏位
      });
      setState(() {
        messageEditionController.text = "";
      });
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                controller: scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  FutureData.readAlready(widget.ID, Me.me!.IDnumber);
                  return ChatMessage(
                    message: snapshot.data!.docs[index]["message"],
                    sendByMe:
                        Me.me!.IDnumber == snapshot.data!.docs[index]["sendBy"],
                  );
                });
          }
          return Container();
        });
  }
}
