import 'package:flutter/material.dart';

class ImageListView extends StatelessWidget {
  final ScrollController scrollController;
  final List images;

  const ImageListView({super.key,  required this.scrollController, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:70,
      child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  'assets/images/${images[index]}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
    );
  }
}
