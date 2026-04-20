
import 'package:flutter/material.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
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
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme:  IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        title: const Text('Start With Function',style: TextStyle(color: Colors.white),),
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


