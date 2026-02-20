
import 'package:flutter/material.dart';
import 'package:four_ideas/helper/app_background.dart';

class StartWithFunctionScreen extends StatefulWidget {
  const StartWithFunctionScreen({super.key});

  @override
  State<StartWithFunctionScreen> createState() => _StartWithFunctionScreenState();
}

class _StartWithFunctionScreenState extends State<StartWithFunctionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:  IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: const Text('Start With Function',style: TextStyle(color: Colors.white),),
      ),
      body: const Stack(
        children: [
          AppBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Text('Page under construction',style: TextStyle(fontSize: 32,color: Colors.white),)),
            ],
          )
          // CustomScrollView(
          //   slivers: [
          //     SliverToBoxAdapter(
          //       child:
          //     ),
          //     SliverToBoxAdapter(
          //
          //     )
          //   ],
          // )
        ],
      ),
    );
  }
}


