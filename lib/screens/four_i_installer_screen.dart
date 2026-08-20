import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';

const _repository = 'https://github.com/johnacolani/4iInstaller';

class FourIInstallerScreen extends StatefulWidget {
  const FourIInstallerScreen({super.key});

  @override
  State<FourIInstallerScreen> createState() => _FourIInstallerScreenState();
}

class _FourIInstallerScreenState extends State<FourIInstallerScreen> {
  final _howItWorksKey = GlobalKey();

  Future<void> _openGitHub() => launchUrl(
        Uri.parse(_repository),
        mode: LaunchMode.externalApplication,
      );

  void _showHowItWorks() {
    final target = _howItWorksKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final horizontal = mobile ? 20.0 : 48.0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        leading: FrostedAppBar.backLeading(context, tooltip: 'Back'),
        title: const Text('4iInstaller',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF071426),
                Color(0xFF121827),
                Color(0xFF08101D)
              ]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontal, 68, horizontal, 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('4iDEAS DEVELOPER TOOLS', style: _eyebrow),
                      const SizedBox(height: 15),
                      Text('4iInstaller', style: _title(mobile ? 44 : 66)),
                      const SizedBox(height: 12),
                      Text('Build Windows installers for Flutter.',
                          style: _title(mobile ? 30 : 45)),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 790),
                        child: Text(
                            'A free reusable installer tool for Flutter Windows applications. Install it once, use it from any terminal, and create professional setup executables for your Flutter projects.',
                            style: _body(mobile ? 17 : 20)),
                      ),
                      const SizedBox(height: 28),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        FilledButton.icon(
                            onPressed: _openGitHub,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('View on GitHub')),
                        OutlinedButton.icon(
                            onPressed: _showHowItWorks,
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text('How It Works')),
                      ]),
                      const SizedBox(height: 76),
                      _Section(
                        key: _howItWorksKey,
                        eyebrow: 'SIMPLE WORKFLOW',
                        title: 'How it works',
                        child: Column(children: [
                          _Flow(items: const [
                            'Install once',
                            'Open any Flutter Windows project',
                            'Initialize 4iInstaller',
                            'Build',
                            'Receive a Windows setup EXE'
                          ], mobile: mobile),
                          const SizedBox(height: 30),
                          LayoutBuilder(builder: (context, c) {
                            final stacked = c.maxWidth < 760;
                            final init = const _CommandCard(
                                command: '4iinstaller init',
                                detail:
                                    'Creates the installer configuration for the current Flutter project.');
                            final build = const _CommandCard(
                                command: '4iinstaller build',
                                detail:
                                    'Reads the version from pubspec.yaml, builds the Flutter Windows release, and creates the Windows installer.');
                            return stacked
                                ? Column(children: [
                                    init,
                                    const SizedBox(height: 16),
                                    build
                                  ])
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Expanded(child: init),
                                        const SizedBox(width: 16),
                                        Expanded(child: build)
                                      ]);
                          }),
                          const SizedBox(height: 18),
                          const _CodeBlock(
                              text:
                                  'pubspec.yaml\nversion: 1.2.0+120\n\n4iinstaller build\n\ninstaller\\Output\\\n    MyApp-Setup-1.2.0.exe\n    MyApp_Setup.exe'),
                        ]),
                      ),
                      _Section(
                        eyebrow: 'WHY 4iINSTALLER',
                        title: 'Built for repeatable releases',
                        child: _BenefitGrid(mobile: mobile),
                      ),
                      _Section(
                        eyebrow: 'DEVELOPER WORKFLOW',
                        title: 'From Flutter project to installer',
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _CodeBlock(
                                  text:
                                      'cd C:\\Projects\\MyFlutterApp\n4iinstaller init\n\n# For future releases\n4iinstaller build'),
                              const SizedBox(height: 24),
                              _Flow(items: const [
                                'Flutter Project',
                                '4iInstaller',
                                'Windows Release Build',
                                'MyApp-Setup-1.2.0.exe'
                              ], mobile: mobile),
                            ]),
                      ),
                      _Section(
                        eyebrow: 'OPEN SOURCE',
                        title: 'Developed openly on GitHub',
                        child: _Panel(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  'Developers can inspect the source, report issues, contribute improvements, and follow future releases.',
                                  style: _body(16)),
                              const SizedBox(height: 18),
                              Text(
                                  'The downloadable CLI release is being prepared and verified. Until it is published, use the repository to follow progress; no unverified installation command is shown here.',
                                  style: _body(14)),
                              const SizedBox(height: 22),
                              FilledButton.icon(
                                  onPressed: _openGitHub,
                                  icon: const Icon(Icons.open_in_new),
                                  label:
                                      const Text('View 4iInstaller on GitHub')),
                            ])),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.child});
  final String eyebrow, title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow, style: _eyebrow),
          const SizedBox(height: 10),
          Text(title,
              style: _title(MediaQuery.sizeOf(context).width < 700 ? 28 : 38)),
          const SizedBox(height: 28),
          child,
        ]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: ColorManager.accentGold.withValues(alpha: .24))),
        child: child,
      );
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({required this.command, required this.detail});
  final String command, detail;
  @override
  Widget build(BuildContext context) => _Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SelectableText(command, style: _mono(17, ColorManager.accentGold)),
        const SizedBox(height: 12),
        Text(detail, style: _body(15)),
      ]));
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF050A12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12)),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(text,
                style: _mono(14, Colors.white.withValues(alpha: .86)))),
      );
}

class _Flow extends StatelessWidget {
  const _Flow({required this.items, required this.mobile});
  final List<String> items;
  final bool mobile;
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12)),
          child: Text(items[i],
              textAlign: TextAlign.center,
              style: _body(14).copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600))));
      if (i < items.length - 1) {
        children.add(Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(mobile ? Icons.arrow_downward : Icons.arrow_forward,
                color: ColorManager.accentGold, size: 20)));
      }
    }
    return mobile
        ? Column(children: children)
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: children);
  }
}

class _BenefitGrid extends StatelessWidget {
  const _BenefitGrid({required this.mobile});
  final bool mobile;
  static const benefits = [
    (
      'Install Once',
      'Use it from PowerShell, Windows Terminal, or the VS Code terminal.'
    ),
    (
      'Built for Flutter',
      'Designed specifically around Flutter Windows release builds.'
    ),
    ('Reusable', 'Use the same tool with multiple Flutter applications.'),
    (
      'Automatic Version Detection',
      'Reads the app version and build number from pubspec.yaml.'
    ),
    (
      'Self-Contained Setup',
      'Packages the Flutter release files into a Windows setup executable.'
    ),
    (
      'Windows Integration',
      'Supports Program Files, shortcuts, Installed Apps, uninstall, and optional file associations.'
    ),
    (
      'Free and Open Source',
      'The project source is available publicly on GitHub.'
    ),
    (
      'No Commercial Builder Required',
      'Normal use does not depend on a paid installer-building product.'
    ),
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = mobile ? 1 : (c.maxWidth < 980 ? 2 : 3);
        const gap = 14.0;
        final width = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final item in benefits)
            SizedBox(
                width: width,
                child: _Panel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Icon(Icons.check_circle_outline,
                          color: ColorManager.accentGold),
                      const SizedBox(height: 12),
                      Text(item.$1, style: _title(18)),
                      const SizedBox(height: 8),
                      Text(item.$2, style: _body(14))
                    ])))
        ]);
      });
}

final _eyebrow = GoogleFonts.roboto(
    color: ColorManager.accentGold,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5);
TextStyle _title(double size) => GoogleFonts.roboto(
    color: Colors.white,
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1.08);
TextStyle _body(double size) => GoogleFonts.roboto(
    color: Colors.white.withValues(alpha: .72), fontSize: size, height: 1.55);
TextStyle _mono(double size, Color color) => GoogleFonts.robotoMono(
    color: color, fontSize: size, height: 1.55, fontWeight: FontWeight.w600);
