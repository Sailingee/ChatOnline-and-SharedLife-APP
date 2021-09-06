import 'package:cloud_firestore/cloud_firestore.dart';
class Message {
  Message(
      this.imageListUrl, this.head_picture, this.name, this.title, this.article,
      {this.imageUrl,
      this.creatorID,
      this.messageID
      });

  Message.upLoad(this.title, this.article, this.imageUrl);

  Message.downLoad(this.imageListUrl, this.head_picture, this.name, this.title,
      this.article, this.messageID, this.creatorID, this.likes,
      {this.isLike = false,this.commonts}){
    initiaComments();
  }

  //创造者的ID 和 文章的ID
  String? creatorID;
  num? messageID;

  //图片集合外链
  late List<String> imageListUrl;

  //图片文件夹路径
  String? imageUrl;

  //头像外链
  late String head_picture;

  //创建人的名字
  late String name;

  //文章的标题 和 内容
  String title;
  String article;

  //评论集合
  CollectionReference<Map<String, dynamic>>? commonts;

  initiaComments(){
    this.commonts = FirebaseFirestore.instance.collection('messages').doc(creatorID!+messageID.toString()).collection('Comments');

  }

  //点赞列表
  bool isLike = false;
  late Map likes;
}
