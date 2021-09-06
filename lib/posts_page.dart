import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/MainPage/item/Message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late TextEditingController articleController;
  late TextEditingController titleController;
  var _imgPath;
  List<String> imageList = ['add'];

  @override
  void initState() {
    articleController = new TextEditingController();
    titleController = new TextEditingController();
    super.initState();
  }

  /*自定义AppBar*/
  Widget customAppBar() {
    return Container(
      height: AppBar().preferredSize.height,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 15),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(right: 15),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (contex) {
                        return AlertDialog(
                          title: Center(child: Text('正在上传')),
                          contentPadding: EdgeInsets.fromLTRB(123, 0, 123, 0),
                          content: CircularProgressIndicator(),
                        );
                      });
                  uploadFile().then((isOK) {
                    if (isOK) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false);
                    } else {
                      Fluttertoast.showToast(
                          msg: 'ERROR UPLOAD', toastLength: Toast.LENGTH_LONG);
                      Navigator.pop(context);
                    }
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                ),
                child: Text('上传'),
              )),
        ],
      ),
    );
  }

  /*上传图片区域*/
  Widget photoArea() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      //color: Colors.blue,
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: GridView(
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        children: buildImage(),
      ),
    );
  }

  /*文章输入栏*/
  Widget inputArea() {
    return Container(
      height: MediaQuery.of(context).size.width,

      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                '标题:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  controller: titleController,
                  maxLines: 1,
                ),
              ))
            ],
          ),
          Container(
            child: Text(
              '文章内容',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            margin: EdgeInsets.only(top: 10),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              controller: articleController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.multiline,
              maxLines: 13,
            ),
          ))
        ],
      ),
    );
  }

  //主界面容器
  Widget mainWidget() {
    return SafeArea(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customAppBar(),
                    photoArea(),
                  ],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: inputArea(),
                ),

              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: mainWidget());
  }

  //图片集合 最多8张图片
  List<Widget> buildImage() {
    List<Widget> res = [];
    for (int i = 0; i < imageList.length; ++i) {
      if (i == imageList.length - 1) {
        if (i <= 7)
          res.add(addImageIcon());
        else {
          return res;
        }
      } else {
        res.add(Image.file(
          File(imageList[i]),
          fit: BoxFit.fill,
        ));
      }
    }
    return res;
  }

  /*添加图片的图标+号 */
  Widget addImageIcon() {
    return Container(
      width: 48,
      height: 48,
      child: InkWell(
        onTap: () async {
          await _openGallery();
          String path = _imgPath;
          if (path == '') {
            return;
          }
          imageList.insert(imageList.length - 1, _imgPath);
          Future.delayed(Duration(seconds: 1), () {
            setState(() {});
          });
        },
        child: Image.asset(
          'assets/images/添加图片.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  /*图片控件*/
  Widget _ImageView(imgPath) {
    if (imgPath == null) {
      return Center(
        child: Text("请选择图片或拍照"),
      );
    } else {
      return Image.file(
        File(imgPath),
      );
    }
  }

  /*拍照*/
  _takePhoto() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    try {
      setState(() {
        _imgPath = image!.path;
      });
    } catch (e) {
      print(e);
    }
  }

  /*相册*/
  Future<void> _openGallery() async {
    var xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    try {
      if (xfile == null) print('null');
      _imgPath = xfile!.path;
    } catch (e) {
      _imgPath = '';
    }
  }

  /*上传操作*/
  Future<bool> uploadFile() async {
    Me me = Me.getInstance();
    if (me == null) return false;
    String mainDir = me.IDnumber.toString();
    String upDir = mainDir + me.Posts.length.toString();
    late File file;
    for (int i = 0; i < imageList.length - 1; ++i) {
      file = File(imageList[i]);
      try {
        await firebase_storage.FirebaseStorage.instance
            .ref('uploads/$mainDir/$upDir/${i.toString()}.jpg')
            .putFile(file);
      } catch (e) {
        print(e);
      }
    }
    Message mes = new Message.upLoad(titleController.text,
        articleController.text, 'uploads/$mainDir/$upDir/');
    CollectionReference ref = FirebaseFirestore.instance.collection('messages');
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    await ref
        .doc(upDir)
        .set({
          'article': articleController.text,
          'comments': [],
          'creator': users.doc(me.docId.toString()),
          'creatorID': me.IDnumber,
          'imageLength': imageList.length - 1,
          'imageUrl': 'uploads/$mainDir/$upDir/',
          'likes': {},
          'title': titleController.text,
          'messageID': me.Posts.length,
          'date': DateTime.now()
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));


    me.Posts.add(ref.doc(upDir));

    users
        .doc(me.docId.toString())
        .update({'Posts': me.Posts})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));

    return true;
  }
}
