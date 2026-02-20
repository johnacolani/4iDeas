import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    double he=MediaQuery.of(context).size.height;
    double wi=MediaQuery.of(context).size.width;
    return  DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff051136).withValues(alpha: 0.7),
        body: Center(
          child: Container(
            color: Colors.transparent,
            width: wi,
            height: he,
          ),
        ),
      ),
    );
  }
}
