import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:danc/Logic/Me.dart';
import 'package:danc/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';


class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {

  String _imgPath = '';
  TextEditingController name = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),onPressed: (){
          Navigator.pop(context);
        },),
        backgroundColor: Colors.redAccent,

      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width*0.2,
                  child: InkWell(
                    child: Stack(
                      children: [
                        Align(alignment: Alignment.centerLeft,child: Text("选择头像图片",style: TextStyle(fontSize: 20),),),
                        Align(alignment: Alignment.centerRight,child: Container(height: 70,width: 70,child: Image.asset("assets/images/添加图片.png"),))
                      ],
                    ),
                    onTap: (){
                      _openGallery();
                    },
                  ),
                ),
                Divider(height: 1,),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Text("名 字 : ",style: TextStyle(fontSize: 20),),
                    Expanded(child: TextField(controller: name,))
                  ],
                )
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.redAccent)
                  ),
                  onPressed: (){
                    upLoad();
                  },
                  child: Text("修改"),
                ),
              )
            )
          ],
        )
      ),
    );
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

  upLoad() async {
    if(_imgPath==''){
      Fluttertoast.showToast(msg: "请选择图片",toastLength: Toast.LENGTH_LONG);
      return;
    }
    String path = "uploads/${Me.me!.IDnumber}/headImage.png";
    try{
      File file = File(_imgPath);
      //上传图片
      await firebase_storage.FirebaseStorage.instance
          .ref(path)
          .putFile(file);
      //上传名字
      FirebaseFirestore.instance.collection("users").doc(Me.me!.IDnumber).update(
          {"name": name.text,"headImage":"uploads/${Me.me!.IDnumber}"}).then((value){
            Me.me!.headImage = "uploads/${Me.me!.IDnumber}";
            Me.me!.getHeadImage();
            Me.me!.name = name.text;

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);

          }).catchError((error){
            Navigator.pop(context);
            print(error);
      });
      Fluttertoast.showToast(msg: "修改成功",toastLength: Toast.LENGTH_LONG);

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (contex) {
            return AlertDialog(
              title: Center(child: Text('正在验证')),
              contentPadding: EdgeInsets.fromLTRB(123, 0, 123, 0),
              content: CircularProgressIndicator(),
            );
          });
      //Navigator.pop(context);


    }
    catch(e){
      Fluttertoast.showToast(msg: "网络错误",toastLength: Toast.LENGTH_LONG);
    }




  }

}
