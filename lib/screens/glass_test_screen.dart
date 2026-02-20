import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Test screen to compare different liquid glass packages
/// Switch between packages by uncommenting the one you want to test
class GlassTestScreen extends StatefulWidget {
  const GlassTestScreen({super.key});

  @override
  State<GlassTestScreen> createState() => _GlassTestScreenState();
}

class _GlassTestScreenState extends State<GlassTestScreen> {
  String selectedPackage = 'none';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.pink.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Package selector
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Select Glass Package to Test',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildPackageButton('none', 'Native BackdropFilter'),
                            _buildPackageButton('liquid_glass_effect', 'liquid_glass_effect'),
                            _buildPackageButton('oc_liquid_glass', 'oc_liquid_glass'),
                            _buildPackageButton('liquid_glass_animation', 'liquid_glass_animation'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Glass effect test area
              Expanded(
                child: Center(
                  child: _buildGlassEffect(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageButton(String package, String label) {
    final isSelected = selectedPackage == package;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedPackage = package;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  Widget _buildGlassEffect() {
    switch (selectedPackage) {
      case 'none':
        return _buildNativeBackdropFilter();
      case 'liquid_glass_effect':
        return _buildLiquidGlassEffect();
      case 'oc_liquid_glass':
        return _buildOcLiquidGlass();
      case 'liquid_glass_animation':
        return _buildLiquidGlassAnimation();
      default:
        return _buildNativeBackdropFilter();
    }
  }

  // Native Flutter BackdropFilter (current implementation)
  Widget _buildNativeBackdropFilter() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'Native BackdropFilter\n(Current Implementation)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Package 1: liquid_glass_effect
  Widget _buildLiquidGlassEffect() {
    // TODO: Uncomment when package is added
    // import 'package:liquid_glass_effect/liquid_glass_effect.dart';
    // return LiquidGlassCard(
    //   child: Container(
    //     width: 300,
    //     height: 200,
    //     child: Center(
    //       child: Text(
    //         'liquid_glass_effect Package',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //   ),
    // );
    
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Package not yet added.\nAdd to pubspec.yaml:\n\nliquid_glass_effect: ^0.1.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Package 2: oc_liquid_glass
  Widget _buildOcLiquidGlass() {
    // TODO: Uncomment when package is added
    // import 'package:oc_liquid_glass/oc_liquid_glass.dart';
    // return OcLiquidGlass(
    //   child: Container(
    //     width: 300,
    //     height: 200,
    //     child: Center(
    //       child: Text(
    //         'oc_liquid_glass Package',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //   ),
    // );
    
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Package not yet added.\nAdd to pubspec.yaml:\n\noc_liquid_glass: ^0.1.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Package 3: liquid_glass_animation
  Widget _buildLiquidGlassAnimation() {
    // TODO: Uncomment when package is added
    // import 'package:liquid_glass_animation/liquid_glass_animation.dart';
    // return LiquidGlassAnimation(
    //   child: Container(
    //     width: 300,
    //     height: 200,
    //     child: Center(
    //       child: Text(
    //         'liquid_glass_animation Package',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //   ),
    // );
    
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Package not yet added.\nAdd to pubspec.yaml:\n\nliquid_glass_animation: ^0.1.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

