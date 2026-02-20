import 'dart:async';

import 'package:flutter/material.dart';

class AutoScrollImage extends StatefulWidget {
  const AutoScrollImage({super.key});

  @override
  _AutoScrollImageState createState() => _AutoScrollImageState();
}

class _AutoScrollImageState extends State<AutoScrollImage> {

  final ScrollController _scrollController = ScrollController();
  final int itemCount = 10;
  final double itemWidth = 80.0;
  final Duration autoScrollDuration = const Duration(seconds: 1);
  final Duration timerInterval = const Duration(seconds: 3);
  Timer? _timer;
  bool scrollingRight = true;

  @override
  void initState() {
    super.initState();
    startAutoScroll();
  }

  void startAutoScroll() {
    _timer = Timer.periodic(timerInterval, (timer) {
      if (_scrollController.hasClients) {
        double targetPosition;
        if (scrollingRight) {
          targetPosition = _scrollController.position.pixels + itemWidth;
        } else {
          targetPosition = _scrollController.position.pixels - itemWidth;
        }

        if (targetPosition >= 0 &&
            targetPosition <= _scrollController.position.maxScrollExtent) {
          // Scroll to the target position
          _scrollController.animateTo(
            targetPosition,
            duration: autoScrollDuration,
            curve: Curves.easeInOut,
          );
        } else {
          // Stop scrolling at the end
          _timer?.cancel();
          // Delay for a moment to pause at the end
          Future.delayed(const Duration(seconds: 2), () {
            // Change direction
            scrollingRight = !scrollingRight;
            // Restart auto-scrolling
            startAutoScroll();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65.0,
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // Reverse the list to make it scroll from right to left
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Use different images for each item
          String imagePath =
              'assets/scroller_images/image_$index.png'; // Adjust the image path

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              width: itemWidth,
              margin: const EdgeInsets.all(8.0),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 80.0, // Adjust the width as needed
                  height: 80.0, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
