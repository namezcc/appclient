import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key,this.minScale,this.maxScale,
    this.heroTag = "simple"
  });

  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (Get.arguments["url"] != null) {
      String url = Get.arguments["url"];
      imageProvider = CachedNetworkImageProvider(url);
    }

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                enableRotation: true,
              ),
            ),
            Positioned(//右上角关闭按钮
              right: 10,
              top: MediaQuery.of(context).padding.top,
              child: IconButton(
                icon:const Icon(Icons.close,size: 30,color: Colors.white,),
                onPressed: (){
                  Get.back();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  
}