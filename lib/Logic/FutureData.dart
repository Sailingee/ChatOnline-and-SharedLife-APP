import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/Follower.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/Message.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FutureData {
  static Future<Message> getCollectionStreamMessage(dc) async {
    var ref = dc['collection'];
    int start = ref.toString().indexOf("(") + 1;
    int end = ref.toString().indexOf(")");
    var doc_ref = ref.toString().substring(start, end);
    return await FirebaseFirestore.instance.doc(doc_ref).get().then((docs) {
      return getStreamMessage(docs);
    });
  }

  //获取每一条Message快照
  static Future<Message> getStreamMessage(dc) async {
    late List<String> imagesUrl = [];
    late String head_picture;
    late String name;
    String title = dc['title'];
    String article = dc['article'];
    num messageID = dc['messageID'];
    String creatorID = dc['creatorID'];
    String imageUrl = dc['imageUrl'];

    var usersDoc = dc['creator'];
    var likes = dc['likes'];

    bool isLike = false;
    if (Me.me != null && likes[Me.me!.IDnumber.toString()] == true) {
      isLike = true;
    }
    for (int i = 0; i < dc['imageLength']; ++i) {
      String downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref('${imageUrl}$i.jpg')
          .getDownloadURL();
      imagesUrl.add(downloadUrl);
    }
    await usersDoc.get().then((snap) async {
      name = snap['name'];
      head_picture = snap['headImage'];
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('${head_picture}/headImage.png')
          .getDownloadURL();
      head_picture = downloadURL;
    });
    Message ms;

    ms = Message.downLoad(imagesUrl, head_picture, name, title, article,
        messageID, creatorID, likes,
        isLike: isLike);

    return ms;
  }

  //认证用户
  static Future<bool?> authorization(
      TextEditingController userName, TextEditingController password) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    return ref
        .where('IDnumber', isEqualTo: userName.text.toString())
        .where('password', isEqualTo: password.text.toString())
        .get()
        .then((value) {
      int count = 0;
      late String IDnumber;
      late String name;
      late String password;
      late String headImage;
      late int docId;
      value.docs.forEach((element) async {
        count++;
        IDnumber = element['IDnumber'];
        name = element['name'];
        password = element['password'];
        headImage = element['headImage'];
        docId = element['docID'];
      });
      if (count == 1) {
        Me me = Me.getInstance();
        LoginCache(IDnumber, name, password, headImage, docId);
        me.initia(IDnumber, name, password, headImage, docId);
        return true;
      }
    }).catchError((e) {
      print(e);
      return false;
    });
  }

  //登陆缓存
  static Future<void> LoginCache(String IDnumber, String name, String password,
      String headImage, int docId) async {
    SharedPreferences person = await SharedPreferences.getInstance();
    person.setBool("isLogin", true);
    person.setString("IDnumber", IDnumber);
    person.setString("name", name);
    person.setString("password", password);
    person.setString("headImage", headImage);
    person.setInt("docId", docId);
  }

  //在数据库中寻找IDnumber是该数字的用户
  static Future<QuerySnapshot> searchByIDnumber(String IDnumber) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('IDnumber', isEqualTo: IDnumber)
        .get();
  }

  static Future<QuerySnapshot> searchByName(String name) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get();
  }

  static getMessageSnap() async {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static getCollectionSnap() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(Me.me!.IDnumber)
        .collection('collections')
        .snapshots();
  }

  static getHotMessageSnap() async {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('like_amount', descending: true)
        .snapshots();
  }

  static getSearchMessageSnap(String search) async {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('title', isGreaterThanOrEqualTo: search)
        .where('title', isLessThan: search + 'zzzzzzzzzzzzzz')
        .snapshots();
  }

  //获取聊天数据库快照
  static getUserChats(String IDnumber) async {
    return FirebaseFirestore.instance
        .collection('ChatWith')
        .where('users', arrayContains: IDnumber)
        .snapshots();
  }

  //向数据库中添加聊天室
  static creatChatRoom(String opID) {
    if (opID == Me.me!.IDnumber) return;
    String ID = Me.me!.IDnumber + "_" + opID;
    FirebaseFirestore.instance.collection('ChatWith').doc(ID).set({
      opID: true,
      Me.me!.IDnumber: true,
      "id": ID,
      "time": DateTime.now(),
      "users": [Me.me!.IDnumber, opID]
    });
  }

  //每个用户都有唯一的ID值和唯一文档，返回该文档
  static getUserDoc(String IDnumber) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('IDnumber', isEqualTo: IDnumber)
        .get()
        .then((docs) {
      return docs.docs[0];
    }).catchError((error) {
      print(error);
    });
  }

  //头像文件收藏在Store中 而非cloud store需要额外的网络请求获取真正的外链
  static getHeadImage(String headImageUrl) async {
    return await firebase_storage.FirebaseStorage.instance
        .ref('${headImageUrl}/headImage.png')
        .getDownloadURL();
  }

  //向双方聊天室中添加消息
  static Future<void> addMessage(String ID, chatMessageData) async {
    FirebaseFirestore.instance
        .collection("ChatWith")
        .doc(ID)
        .collection("record")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });

    FirebaseFirestore.instance
        .collection("ChatWith")
        .doc(ID)
        .update({"time": DateTime.now()});
  }

  //获取聊天记录
  static getRecord(String ID) {
    return FirebaseFirestore.instance
        .collection("ChatWith")
        .doc(ID)
        .collection("record")
        .orderBy('time')
        .snapshots();
  }

  //已读 未读信息脏位消除
  static readAlready(String ID, String MyID) {
    FirebaseFirestore.instance
        .collection('ChatWith')
        .doc(ID)
        .update({MyID: true});
  }

  //设置脏位表示未读信息
  static setUnRead(String ID, String MyID) {
    final opID = ID.replaceAll("_", "").replaceAll(MyID, "");
    FirebaseFirestore.instance
        .collection('ChatWith')
        .doc(ID)
        .update({opID: false});
  }

  static Future<Follower> getFollower(doc) async {
    Follower follower = new Follower();
    var ref = FirebaseFirestore.instance.doc(doc);
    print("ref!!");
    print(ref);
    return ref.get().then((value) async {
      print("ref start");
      follower.IDnumber = value["IDnumber"];
      print(follower.IDnumber);
      follower.headImage = value["headImage"];
      follower.name = value["name"];

      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('${follower.headImage}/headImage.png')
          .getDownloadURL();
      print('${follower.headImage}/headImage.png');
      follower.headImage = downloadURL;
      print("follower end");
      return follower;
    });
  }

  static Future<void> collection_click(doc) async {
    Me me = Me.getInstance();
    FirebaseFirestore.instance
        .collection("users")
        .doc(me.IDnumber)
        .collection("collections")
        .add({"collection": doc});
  }

  static Future<void> follow_click(doc) async {
    int start = doc.toString().lastIndexOf("/") + 1;
    int end = doc.toString().indexOf(")");
    String path = doc.toString().substring(start, end);
    Me me = Me.getInstance();
    FirebaseFirestore.instance
        .collection("users")
        .doc(me.IDnumber)
        .collection("follows")
        .doc(path)
        .set({
      "news": false,
      "follow": doc,
    });
     var mine =  FirebaseFirestore.instance.collection("users").doc(Me.me!.IDnumber);
    FirebaseFirestore.instance
        .collection("users")
        .doc(path)
        .collection("followers")
        .doc(Me.me!.IDnumber)
        .set({
      "follower": mine
    });
  }
}

class UserRequired {
  static Future<bool> signUpAuthorization(
      String IDnumber, String name, String password) async {
    if (authorFormat(IDnumber, name, password) == false) {
      return false;
    }
    await FirebaseFirestore.instance
        .collection("users")
        .where("IDnumber", isEqualTo: IDnumber)
        .get()
        .then((docs) {
      if (docs.docs.length >= 1) {
        return false;
      }
    });

    return await FirebaseFirestore.instance
        .collection("users")
        .doc(IDnumber)
        .set({
          "IDnumber": IDnumber,
          "docID": num.parse(IDnumber),
          "LikeIDnumber": [],
          "Posts": [],
          "name": name,
          "password": password,
          "headImage": "/uploads"
        })
        .then((value) => true)
        .catchError((error) {
          print(error);
          return false;
        });
  }

  //添加收藏
  static Future<bool> collection(Message msg) async {
    //查询
    Me me = Me.getInstance();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(me.IDnumber)
        .collection("collections")
        .where("messageID", isEqualTo: msg.messageID)
        .get()
        .then((docs) {
      if (docs.docs.length >= 1) {
        return false;
      }
    });
    //FirebaseFirestore.instance.collection("user").doc(me.IDnumber).collection("collections").add();
    return true;
  }

  static bool authorFormat(String IDnumber, String name, String password) {
    try {
      if (IDnumber.length != 11) {
        Fluttertoast.showToast(
            msg: "请输入正确的11位手机号码", toastLength: Toast.LENGTH_LONG);
        return false;
      }
      num.parse(IDnumber);
      return true;
    } catch (error) {
      Fluttertoast.showToast(
          msg: "请输入正确的11位手机号码", toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  static Future<String> downloadUrl(String path) async {
    return await firebase_storage.FirebaseStorage.instance
        .ref('${path}/headImage.png')
        .getDownloadURL();
  }
}
