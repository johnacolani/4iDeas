
import 'package:flutter/material.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';

class StartObjectOrientedProgramScreen extends StatefulWidget {
  const StartObjectOrientedProgramScreen({super.key});

  @override
  State<StartObjectOrientedProgramScreen> createState() => _StartObjectOrientedProgramScreenState();
}

class _StartObjectOrientedProgramScreenState extends State<StartObjectOrientedProgramScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme:  IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        title: const Text('Start Object Oriented',style: TextStyle(color: Colors.white),),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Page under construction',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
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


