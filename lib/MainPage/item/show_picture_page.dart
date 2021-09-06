import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';

class ShowPicturePage extends StatefulWidget {
  ShowPicturePage({Key? key, required this.imageList, required this.index})
      : super(key: key);
  int index = 0;
  List<String> imageList;

  @override
  _ShowPicturePageState createState() => _ShowPicturePageState();
}

class _ShowPicturePageState extends State<ShowPicturePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Swiper(
        itemCount: widget.imageList.length,
        index: widget.index,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            //PhotoView 可以让图片拥有手势操作
              child: PhotoView(
            imageProvider:
                NetworkImage(widget.imageList[index]),
          ));
        },
        pagination: new SwiperPagination(
            builder: DotSwiperPaginationBuilder(
                color: Colors.black54, activeColor: Colors.white, size: 8)),
      ),
    );
  }
}
