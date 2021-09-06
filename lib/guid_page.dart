import 'package:danc/index_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
class GuidPage extends StatefulWidget {
  GuidPage({Key? key}) : super(key: key);

  @override
  _GuidState createState() => _GuidState();
}

class _GuidState extends State<GuidPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper(
        itemBuilder: (BuildContext context, int index) {
          if (index == 2) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,

                  child: Image.asset(
                    "assets/images/3.0/yindao${index + 1}.jpeg",
                    fit: BoxFit.fill,
                  ),),
                Positioned(
                    bottom: 200,
                    left: 140,
                    right: 140,
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        child: Text('Start',style: TextStyle(fontSize: 25),),
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    side:
                                    BorderSide(
                                        color: Colors.blue.shade100,
                                        width: 2),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50))))),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => IndexPage()),
                                  (route) => false);
                        },
                      ),
                    )),
                Container(margin: EdgeInsets.all(20),child: Center(

                  child: Text("该程序使用Google Firebase进行存储，请使用该程序前确保可以正常连接外网",style: TextStyle(color: Colors.white,fontSize: 20),),
                ),)


              ],
            );
          }

          return new Image.asset(
            "assets/images/3.0/yindao${index + 1}.jpeg",
            fit: BoxFit.fill,
          );
        },
        loop: false,

        ///页面数
        itemCount: 3,

        ///圆点指示
        pagination: new SwiperPagination(),

        ///控制器 左右点击
        //control: new SwiperControl(),
      ),
    );
  }
}
