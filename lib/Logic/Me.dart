import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/MainPage/item/Message.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

class Me {
  late String IDnumber; //数据库里面转换为 num类型
  late String name;
  late String? password;
  late String headImage;//just file path not imageurl(String)
  late int docId;
  late String head_picture;//imageurl
  List Posts = [];
  List<String> FavoriteIDnumber = [];
  List<String> LikeIDnumber = [];
  List<String> PostsIDnumber = [];
  static Me? me = null;

  static getInstance() {
    if (me == null) {
      me = new Me();
    }
    return me;
  }
  Me();
  Future<void> getHeadImage() async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('${me!.headImage}/headImage.png')
        .getDownloadURL();
    head_picture = downloadURL;
  }
  Future<void> initia(String IDnumber, String name, String password, String headImage,
      int docId) async {
    this.IDnumber = IDnumber;
    this.name = name;
    this.password = password;
    this.headImage = headImage;
    this.docId = docId;
    await getHeadImage();
  }

  Future<void> upLoadComment(Message message, String name, String comment) async{

    CollectionReference mess = await FirebaseFirestore.instance.collection('messages');
    mess
        .doc(message.creatorID.toString() + message.messageID.toString()).collection('Comments')
        .add({'comment': comment,'name':name,'head_image':Me.me!.head_picture})
        .then((value) => print("message Updated"))
        .catchError((error) => print("Failed to update message: $error"));
  }

  Future<void> upLoadLike(Message message,Map likes) async{
    CollectionReference mess = await FirebaseFirestore.instance.collection('messages');
    mess
        .doc(message.creatorID.toString() + message.messageID.toString())
        .update({'likes': likes})
        .then((value) => print("message Updated"))
        .catchError((error) => print("Failed to update message: $error"));
  }

}
