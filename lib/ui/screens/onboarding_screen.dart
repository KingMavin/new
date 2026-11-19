import 'package:flutter/material.dart';

import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class OnboardingDialog extends StatefulWidget {
  final GameController controller;
  final VoidCallback onDone;

  const OnboardingDialog({
    super.key,
    required this.controller,
    required this.onDone,
  });

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _Slide {
  final String asset;
  final String title;
  final String body;

  const _Slide(this.asset, this.title, this.body);
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const List<_Slide> _slides = [
    _Slide(
      'home',
      'Immortal Path',
      'You take your first breath in a lakeside village \u2014 a mortal among '
          'mortals. But the heavens are watching, and qi runs in your veins '
          'like a second blood. Every legend begins as a nobody sweeping a '
          'temple floor.',
    ),
    _Slide(
      'dao',
      'The Qi Loop',
      'Circulate qi, condense it, and break through. Nine great realms, four '
          'stages each \u2014 and when a major realm gates you, the sky itself '
          'descends as a tribulation of waves. Technique, companion and soul '
          'all shape the climb.',
    ),
    _Slide(
      'world',
      'The Wilds',
      'Hunt spirit beasts for stones, herbs and cores. Hidden realms '
          'whisper from beyond the map; fallen cities keep their own '
          'council. Chance encounters will find you mid-journey \u2014 what '
          'you choose from three options writes your chronicle, and some '
          'choices bind lasting marks to your flesh: boons and banes that '
          'shape this whole life. Even the heavens keep score of scars.',
    ),
    _Slide(
      'sect',
      'Sects & the Forge',
      'Swear to a sect to earn rank, missions and disciples. In the armory '
          'buy steel with spirit stones \u2014 or hammer it yourself at the '
          'forge, where success is never promised and failure still costs '
          'the materials.',
    ),
    _Slide(
      'store',
      'The Temple of Support',
      'The game is free to climb, forever. Temple blessings from ads are '
          'always opt-in. The Temple sells conveniences and finery \u2014 '
          'the path itself asks only for patience. When you are ready, '
          'choose your people and take your first step.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    widget.controller.completeIntro();
    Navigator.of(context).pop();
    widget.onDone();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF0C0E14),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  BackdropImage(
                    BackdropCatalog.forScreen(slide.asset),
                    scrim: const [
                      Color(0x22000000),
                      Color(0xCC000000),
                      Color(0xFF0C0E14),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _page
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(
                          _page == _slides.length - 1
                              ? 'Begin the Path'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
