import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:progress_potion/models/character_stats.dart';

class CharacterAvatar extends StatefulWidget {
  const CharacterAvatar({
    super.key,
    required this.stats,
    required this.celebrationCount,
    this.size = const Size(150, 180),
  });

  final CharacterStats stats;
  final int celebrationCount;
  final Size size;

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _celebrationController;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled = MediaQuery.of(context).disableAnimations;
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant CharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrationCount != oldWidget.celebrationCount &&
        !_animationsDisabled) {
      _celebrationController
        ..stop()
        ..forward(from: 0);
    }
  }

  void _syncAnimationState() {
    if (_animationsDisabled) {
      _idleController.stop();
      _celebrationController.stop();
      return;
    }

    if (!_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, _celebrationController]),
      builder: (context, child) {
        final idleOffset = _animationsDisabled
            ? 0.0
            : (_idleController.value - 0.5) * 6;
        final celebrationArc = _animationsDisabled
            ? 0.0
            : math.sin(_celebrationController.value * math.pi) * 14;
        final celebrationRotate = _animationsDisabled
            ? 0.0
            : math.sin(_celebrationController.value * math.pi) * 0.04;

        return SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 8,
                child: Container(
                  width: widget.size.width * 0.46,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, idleOffset - celebrationArc),
                child: Transform.rotate(angle: celebrationRotate, child: child),
              ),
              if (!_animationsDisabled && _celebrationController.value > 0)
                ..._sparkles(theme),
            ],
          ),
        );
      },
      child: _AvatarFigure(size: widget.size, stats: widget.stats),
    );
  }

  List<Widget> _sparkles(ThemeData theme) {
    final opacity = Curves.easeOut.transform(
      1 - _celebrationController.value.clamp(0.0, 1.0),
    );
    final progress = _celebrationController.value;

    return [
      Positioned(
        top: 24 - (progress * 10),
        left: 18,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.secondary,
            size: 16,
          ),
        ),
      ),
      Positioned(
        top: 8 - (progress * 8),
        right: 12,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.primary,
            size: 14,
          ),
        ),
      ),
      Positioned(
        top: 52 - (progress * 12),
        right: 26,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.star_rounded,
            color: theme.colorScheme.tertiary,
            size: 14,
          ),
        ),
      ),
    ];
  }
}

class _AvatarFigure extends StatelessWidget {
  const _AvatarFigure({required this.size, required this.stats});

  final Size size;
  final CharacterStats stats;

  @override
  Widget build(BuildContext context) {
    final strengthLevel = _traitLevel(stats.strength);
    final vitalityLevel = _traitLevel(stats.vitality);
    final wisdomLevel = _traitLevel(stats.wisdom);
    final mindfulnessLevel = _traitLevel(stats.mindfulness);

    final headSize = 68.0 + (wisdomLevel * 2);
    final headTop = 18.0 - (vitalityLevel * 6);
    final neckTop = 74.0 - (vitalityLevel * 5);
    final torsoTop = 86.0 - (vitalityLevel * 8);
    final torsoWidth = 86.0 + (strengthLevel * 16) + (vitalityLevel * 6);
    final torsoHeight = 76.0 + (vitalityLevel * 6);
    final armWidth = 20.0 + (strengthLevel * 7);
    final armHeight = 64.0 + (strengthLevel * 6) + (vitalityLevel * 4);
    final armInset = 12.0 - (strengthLevel * 3) - (vitalityLevel * 2);
    final legInset = 40.0 - (vitalityLevel * 4);
    final stanceWidth = 34.0 + (vitalityLevel * 4);
    final smileSize = Size(
      18 + (mindfulnessLevel * 12),
      7 + (mindfulnessLevel * 7),
    );
    final beardHeight = wisdomLevel <= 0.02 ? 0.0 : 8 + (wisdomLevel * 18);
    final bodyLift = mindfulnessLevel * 2;
    final leftArmAngle =
        -0.22 - (vitalityLevel * 0.08) + (mindfulnessLevel * 0.04);
    final rightArmAngle =
        0.24 + (vitalityLevel * 0.08) - (mindfulnessLevel * 0.04);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: headTop - bodyLift,
            child: Container(
              key: const ValueKey('avatar-head'),
              width: headSize,
              height: headSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF7C4A4), Color(0xFFEEA77E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C2D4E),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22),
                          bottom: Radius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24 - (wisdomLevel * 3),
                    left: 16,
                    child: _Brow(
                      angle: -0.12 + (wisdomLevel * 0.10),
                      width: 12 + (wisdomLevel * 3),
                    ),
                  ),
                  Positioned(
                    top: 24 - (wisdomLevel * 3),
                    right: 16,
                    child: _Brow(
                      angle: 0.12 - (wisdomLevel * 0.10),
                      width: 12 + (wisdomLevel * 3),
                    ),
                  ),
                  Positioned(
                    top: 31,
                    left: 18,
                    child: _FaceDot(smileLevel: mindfulnessLevel),
                  ),
                  Positioned(
                    top: 31,
                    right: 18,
                    child: _FaceDot(smileLevel: mindfulnessLevel),
                  ),
                  if (mindfulnessLevel > 0.08)
                    Positioned(
                      top: 40,
                      left: 11,
                      child: _CheekGlow(
                        opacity: 0.10 + (mindfulnessLevel * 0.12),
                      ),
                    ),
                  if (mindfulnessLevel > 0.08)
                    Positioned(
                      top: 40,
                      right: 11,
                      child: _CheekGlow(
                        opacity: 0.10 + (mindfulnessLevel * 0.12),
                      ),
                    ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        key: const ValueKey('avatar-mouth'),
                        width: smileSize.width,
                        height: smileSize.height,
                        child: CustomPaint(
                          painter: _MouthPainter(smileLevel: mindfulnessLevel),
                        ),
                      ),
                    ),
                  ),
                  if (beardHeight > 0)
                    Positioned(
                      bottom: 4,
                      left: 18 - (wisdomLevel * 4),
                      right: 18 - (wisdomLevel * 4),
                      child: Container(
                        key: const ValueKey('avatar-beard'),
                        height: beardHeight,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF5B4336,
                          ).withValues(alpha: 0.72 + (wisdomLevel * 0.18)),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(18),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: neckTop - bodyLift,
            child: Container(
              width: 20,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFF2B392),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            top: torsoTop - bodyLift,
            child: Container(
              key: const ValueKey('avatar-torso'),
              width: torsoWidth,
              height: torsoHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C6FFF), Color(0xFF2849B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 92 - bodyLift,
            left: armInset,
            child: Transform.rotate(
              angle: leftArmAngle,
              child: _Limb(
                key: const ValueKey('avatar-left-arm'),
                width: armWidth,
                height: armHeight,
                color: Color(0xFFF0B08A),
              ),
            ),
          ),
          Positioned(
            top: 92 - bodyLift,
            right: armInset,
            child: Transform.rotate(
              angle: rightArmAngle,
              child: _Limb(
                width: armWidth,
                height: armHeight,
                color: Color(0xFFF0B08A),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: legInset,
            child: const _Limb(width: 20, height: 74, color: Color(0xFF26304C)),
          ),
          Positioned(
            bottom: 8,
            right: legInset,
            child: const _Limb(width: 20, height: 74, color: Color(0xFF26304C)),
          ),
          Positioned(
            bottom: 0,
            left: 32 - (vitalityLevel * 3),
            child: Container(
              width: stanceWidth,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF17213A),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 32 - (vitalityLevel * 3),
            child: Container(
              width: stanceWidth,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF17213A),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceDot extends StatelessWidget {
  const _FaceDot({required this.smileLevel});

  final double smileLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8 - (smileLevel * 2.4),
      decoration: BoxDecoration(
        color: Color(0xFF3D2B24),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Limb extends StatelessWidget {
  const _Limb({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Brow extends StatelessWidget {
  const _Brow({required this.angle, required this.width});

  final double angle;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: 3.5,
        decoration: BoxDecoration(
          color: const Color(0xFF4D372E),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _CheekGlow extends StatelessWidget {
  const _CheekGlow({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF4A18E).withValues(alpha: opacity),
      ),
    );
  }
}

class _MouthPainter extends CustomPainter {
  const _MouthPainter({required this.smileLevel});

  final double smileLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4E3C)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;

    final smileDepth = 1.0 + (smileLevel * (size.height - 1.5));
    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width / 2,
        smileDepth,
        size.width,
        size.height * 0.45,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MouthPainter oldDelegate) {
    return oldDelegate.smileLevel != smileLevel;
  }
}

double _traitLevel(int value) {
  return (value / 6).clamp(0.0, 1.0);
}
