import 'dart:math' as math;

import 'package:flutter/material.dart';

const forest = Color(0xFF234B3B);
const ink = Color(0xFF253D32);
const muted = Color(0xFF738076);
const canvas = Color(0xFFF7F8F2);
const lime = Color(0xFFDCEBB7);
const line = Color(0xFFE6EAE1);
const amber = Color(0xFFA86B35);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: forest,
    primary: forest,
    surface: Colors.white,
  ),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.4,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: ink),
    bodySmall: TextStyle(fontSize: 12, height: 1.5, color: muted),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      side: const BorderSide(color: line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: canvas,
    contentPadding: const EdgeInsets.all(18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: line),
    ),
  ),
  dividerColor: line,
);

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: line),
    ),
    child: child,
  );
}

class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.color = forest,
    this.background = const Color(0xFFEDF3E6),
    this.icon,
  });
  final String text;
  final Color color;
  final Color background;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(action!, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 15),
              ],
            ),
          ),
      ],
    ),
  );
}

class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    this.color = forest,
    this.background = const Color(0xFFEDF3E6),
    this.size = 44,
  });
  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icon, color: color, size: size * .48),
  );
}

class FarmArt extends StatelessWidget {
  const FarmArt({
    super.key,
    this.variant = 0,
    this.map = false,
    this.points = const [],
  });
  final int variant;
  final bool map;
  final List<Offset> points;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: FarmPainter(variant: variant, map: map, points: points),
    size: Size.infinite,
  );
}

// Original schematic artwork, not satellite imagery.
class FarmPainter extends CustomPainter {
  FarmPainter({this.variant = 0, this.map = false, this.points = const []});
  final int variant;
  final bool map;
  final List<Offset> points;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.clipRect(Offset.zero & s);
    if (map) {
      _map(c, s);
      c.restore();
      return;
    }
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..color = [
          const Color(0xFFE8EDCE),
          const Color(0xFFDFE9DB),
          const Color(0xFFF0E4BF),
        ][variant % 3],
    );
    c.drawCircle(
      Offset(s.width * .78, s.height * .23),
      s.height * .13,
      Paint()..color = const Color(0xFFF8F4D5),
    );
    final colors = [
      const Color(0xFFB8C78D),
      const Color(0xFF8CA46E),
      const Color(0xFF5F8159),
      const Color(0xFF355F49),
    ];
    for (var i = 0; i < 4; i++) {
      final y = s.height * (.36 + i * .17);
      final path = Path()
        ..moveTo(-20, y + 20)
        ..cubicTo(
          s.width * .3,
          y - s.height * .4,
          s.width * .62,
          y + s.height * .3,
          s.width + 20,
          y - s.height * .05,
        )
        ..lineTo(s.width + 20, s.height + 20)
        ..lineTo(-20, s.height + 20)
        ..close();
      c.drawPath(path, Paint()..color = colors[(i + variant) % 4]);
      c.save();
      c.clipPath(path);
      for (var j = 0; j < 20; j++) {
        final x = j * s.width / 12 - s.width * .3;
        c.drawPath(
          Path()
            ..moveTo(x, y - 20)
            ..quadraticBezierTo(
              x + s.width * .12,
              s.height * .75,
              x + s.width * .4,
              s.height + 20,
            ),
          Paint()
            ..color = Colors.white.withValues(alpha: .14)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
      c.restore();
    }
    for (var i = 0; i < 5; i++) {
      final x = s.width * (.13 + i * .045), y = s.height * (.38 - i * .012);
      c.drawLine(
        Offset(x, y),
        Offset(x, y + s.height * .08),
        Paint()
          ..color = forest
          ..strokeWidth = 2,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: s.height * .035,
          height: s.height * .12,
        ),
        Paint()..color = const Color(0xFF345A41),
      );
    }
    c.restore();
  }

  void _map(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFE9EDD9));
    final r = math.Random(28);
    final palette = [
      const Color(0xFFCED9AE),
      const Color(0xFFB6CC9B),
      const Color(0xFFDDE1BD),
      const Color(0xFF9DB88A),
      const Color(0xFFD9D3A3),
    ];
    c.save();
    c.translate(s.width * .5, s.height * .5);
    c.rotate(-.24);
    c.translate(-s.width * .65, -s.height * .7);
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        final rect = Rect.fromLTWH(
          x * s.width * .23,
          y * s.height * .23,
          s.width * .23 - 6,
          s.height * .23 - 6,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = palette[r.nextInt(palette.length)],
        );
        for (var k = 1; k < 7; k++) {
          c.drawLine(
            Offset(rect.left + 4, rect.top + k * rect.height / 7),
            Offset(rect.right - 4, rect.top + k * rect.height / 7),
            Paint()
              ..color = Colors.white.withValues(alpha: .19)
              ..strokeWidth = 1,
          );
        }
      }
    }
    c.restore();
    final river = Path()
      ..moveTo(s.width * .75, -10)
      ..cubicTo(
        s.width * .3,
        s.height * .3,
        s.width * .95,
        s.height * .5,
        s.width * .64,
        s.height + 10,
      );
    c.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFDCE5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28,
    );
    c.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFA1C5C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15,
    );
    final road = Path()
      ..moveTo(-10, s.height * .8)
      ..lineTo(s.width * .45, s.height * .45)
      ..lineTo(s.width + 10, s.height * .33);
    c.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFF8F7E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    if (points.isNotEmpty) {
      final p = Path()
        ..moveTo(points.first.dx * s.width, points.first.dy * s.height);
      for (final o in points.skip(1)) {
        p.lineTo(o.dx * s.width, o.dy * s.height);
      }
      if (points.length > 2) p.close();
      c.drawPath(p, Paint()..color = forest.withValues(alpha: .2));
      c.drawPath(
        p,
        Paint()
          ..color = forest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      for (final o in points) {
        c.drawCircle(
          Offset(o.dx * s.width, o.dy * s.height),
          6,
          Paint()..color = Colors.white,
        );
        c.drawCircle(
          Offset(o.dx * s.width, o.dy * s.height),
          3,
          Paint()..color = forest,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FarmPainter oldDelegate) =>
      oldDelegate.variant != variant ||
      oldDelegate.map != map ||
      oldDelegate.points != points;
}

class WheatArt extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final random = math.Random(6);
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183E32), Color(0xFF647B45)],
        ).createShader(Offset.zero & s),
    );
    for (var i = 0; i < 90; i++) {
      final x = random.nextDouble() * s.width,
          y = random.nextDouble() * s.height;
      final p = Paint()
        ..color = Color.lerp(
          const Color(0xFF506B36),
          const Color(0xFFD4D894),
          random.nextDouble(),
        )!;
      c.drawLine(
        Offset(x, y),
        Offset(x - 25, s.height + 30),
        p..strokeWidth = 2,
      );
      for (var j = 0; j < 7; j++) {
        for (final side in [-1, 1]) {
          c.save();
          c.translate(x + side * 5, y + j * 9);
          c.rotate(side * .6);
          c.drawOval(const Rect.fromLTWH(-3, -12, 6, 19), p);
          c.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
