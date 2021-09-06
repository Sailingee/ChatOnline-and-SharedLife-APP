import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/FutureData.dart';
import 'package:flutter/material.dart';
import 'chat_room.dart';



class SearchChatPage extends StatefulWidget {
  const SearchChatPage({Key? key}) : super(key: key);

  @override
  _SearchChatPageState createState() => _SearchChatPageState();
}

class _SearchChatPageState extends State<SearchChatPage> {
  TextEditingController searchEditingController = new TextEditingController();
  late QuerySnapshot searchResultSnapshot;

  bool isSearching = false;
  bool haveUserSearched = false;
  void onClickSearch() async {
    if (searchEditingController.text.isEmpty) {
      return;
    }
    isSearching = true;
    await FutureData.searchByIDnumber(searchEditingController.text)
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await FutureData.searchByName(searchEditingController.text)
            .then((value) {
          searchResultSnapshot = value;
        });
      } else
        searchResultSnapshot = snapshot;
      setState(() {
        isSearching = false;
        haveUserSearched = true;
      });
    }).catchError((error) {
      print(error);
    });
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.docs[index]['name'],
                searchResultSnapshot.docs[index]["IDnumber"],
              );
            })
        : Container();
  }

  Widget userTile(String opName, String opID) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opName,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Text(
                opID,
                style: TextStyle(color: Colors.black, fontSize: 16),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
                FutureData.creatChatRoom(opID);
                Navigator.push(context,MaterialPageRoute(builder: (context)=>Room(ID: opID,cacheName: opName,)));

            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent[100],
                  borderRadius: BorderRadius.circular(24)),
              child: Text(
                "发送消息",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  AppBar searchAppBar() {
    return AppBar(
      backgroundColor: Colors.deepOrangeAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: TextField(
          controller: searchEditingController,
          cursorHeight: 20,
          textAlignVertical: TextAlignVertical(y: 1),
          decoration: InputDecoration(
            hintText: "需要查找的手机ID或姓名",
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            fillColor: Colors.white,
            filled: true,
          ),
          maxLines: 1,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 10, right: 10),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                onClickSearch();
              });
            },
            child: Text('Search'),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red[400])),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(),
      body: Container(
        margin: EdgeInsets.only(left: 5, top: 5, right: 5),
        child: userList(),
      ),
    );
  }
}
