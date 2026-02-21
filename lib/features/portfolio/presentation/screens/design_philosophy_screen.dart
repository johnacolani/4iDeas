import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/helper/app_background.dart';

/// Global design philosophy and product design principles.
class DesignPhilosophyScreen extends StatelessWidget {
  const DesignPhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    final double sectionTitleSize = isMobile ? 18 : (isTablet ? 20 : 22);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 17);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber[100]),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: SelectableText(
          'Design Philosophy & Principles',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                      vertical: isMobile ? 20 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 800,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            'Integrated Product Design',
                            style: GoogleFonts.albertSans(
                              color: ColorManager.orange,
                              fontSize: sectionTitleSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: he * 0.015),
                          SelectableText(
                            'Understanding humans deeply and solving real problems with care, clarity, and intention.',
                            style: GoogleFonts.albertSans(
                              color: Colors.white,
                              fontSize: bodySize,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: he * 0.04),
                          _PhilosophyBlock(
                            title: 'Design Philosophy — North Star',
                            content:
                                'Design does not begin with screens or tools. It begins with understanding people.\n\n'
                                'In digital products: visual clutter is a cognitive sharp edge; poor hierarchy creates fatigue; ignoring privacy can harm users. A designer\'s role is to protect users, not overwhelm them.',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.025),
                          _PhilosophyBlock(
                            title: 'Empathy as Foundation',
                            content:
                                'Empathy is not a step in the process — it is the foundation of every decision. Users open up only when they feel respected. I avoid long surveys; I prefer conversations and observation; I listen more than I ask. Without empathy, design becomes decoration. AI can analyze patterns, but it cannot feel frustration, fear, or trust. That responsibility remains human.',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.025),
                          _PhilosophyBlock(
                            title: 'End-to-End Process',
                            content:
                                '1. Comprehend & Discover — What problem? Who is affected? In what context?\n'
                                '2. Define Users & Needs — Primary and secondary roles; motivations and frustrations.\n'
                                '3. Prioritize & Frame — Break complexity into parts; prioritize by impact and feasibility.\n'
                                '4. Ideation & Brainstorming — Safe and bold ideas; constraints as creative boundaries.\n'
                                '5. Low-Fidelity Exploration — Sketch concepts, flows, interactions.\n'
                                '6. Wireframes & High-Fidelity — Structure, accessibility, intentional visual choices.\n'
                                '7. Prototyping & Testing — Validate flows; observe emotional response.\n'
                                '8. Evaluation & Iteration — User behavior, feedback, friction; iteration keeps products alive.',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.025),
                          _PhilosophyBlock(
                            title: 'Principles I Live By',
                            content:
                                '• Problem-first thinking\n'
                                '• Deep empathy\n'
                                '• Safety and privacy by design\n'
                                '• Context-aware experiences\n'
                                '• Progressive personalization\n'
                                '• Collaboration over ego\n'
                                '• Iteration over perfection\n'
                                '• Ethics over trends',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.025),
                          _PhilosophyBlock(
                            title: 'Frameworks Used in Practice',
                            content:
                                'Circle Method — Comprehend (goal, users, constraints) → Identify Users (segment by behavior, demographics, context) → Report User Needs → Cut and Prioritize (personas) → List Solutions (safe, ambitious, visionary) → Evaluate Trade-offs → Recommend.\n\n'
                                'STAR — Situation (context, problem, constraints); Task (role, goals, KPIs); Action (research, design, collaboration, iteration); Result (metrics, impact).\n\n'
                                'User Types — Typical users (intuitive nav, clear labels); Frequent users (shortcuts, advanced features); First-time users (onboarding, progressive disclosure).\n\n'
                                'WCAG (Target Level AA) — Perceivable (contrast, typography, alternatives); Operable (keyboard, focus, touch targets); Understandable (consistent nav, error messages); Robust (semantic structure, cross-platform).',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.025),
                          _PhilosophyBlock(
                            title: 'Closing Perspective',
                            content:
                                'Design is not about following frameworks blindly. It is about creating experiences people can feel, trust, and live with — whether physical or digital, small or used by millions. That responsibility drives my work as a product designer.',
                            bodySize: bodySize,
                            he: he,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: he * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhilosophyBlock extends StatelessWidget {
  final String title;
  final String content;
  final double bodySize;
  final double he;
  final bool isMobile;

  const _PhilosophyBlock({
    required this.title,
    required this.content,
    required this.bodySize,
    required this.he,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                title,
                style: GoogleFonts.albertSans(
                  color: ColorManager.orange,
                  fontSize: bodySize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: he * 0.012),
              SelectableText(
                content,
                style: GoogleFonts.albertSans(
                  color: Colors.white,
                  fontSize: bodySize,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
