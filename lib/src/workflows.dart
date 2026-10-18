import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'design.dart';
import 'store.dart';

class FlowDialog extends StatelessWidget {
  const FlowDialog({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.children,
  });
  final String title, eyebrow;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: muted,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 21),
              ),
            ],
          ),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
    if (MediaQuery.sizeOf(context).shortestSide < 600) {
      return Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(child: content),
        ),
      );
    }
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 570),
        child: content,
      ),
    );
  }
}

class AddFieldDialog extends StatefulWidget {
  const AddFieldDialog({super.key, required this.store});
  final FarmStore store;
  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final name = TextEditingController();
  final form = GlobalKey<FormState>();
  String soil = 'Sandy loam', shape = 'Rectangle';
  List<Offset> points = [
    const Offset(.2, .25),
    const Offset(.65, .25),
    const Offset(.65, .7),
    const Offset(.2, .7),
  ];
  String? boundaryError;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  double get acres => polygonArea(points) * 120000 / 4046.8564224;
  void chooseShape(String value) => setState(() {
    shape = value;
    boundaryError = null;
    points = switch (value) {
      'Rectangle' => [
        const Offset(.2, .25),
        const Offset(.65, .25),
        const Offset(.65, .7),
        const Offset(.2, .7),
      ],
      'Circle' => List.generate(
        24,
        (i) => Offset(
          .5 + .24 * math.cos(i * math.pi / 12),
          .5 + .32 * math.sin(i * math.pi / 12),
        ),
      ),
      _ => [],
    };
  });
  @override
  Widget build(BuildContext context) => FlowDialog(
    title: 'Room for something to grow.',
    eyebrow: 'ADD A NEW FIELD',
    children: [
      const Text(
        'Sketch your boundary on the illustrated practice map.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: [
          for (final s in ['Rectangle', 'Polygon', 'Circle'])
            ChoiceChip(
              label: Text(s),
              selected: shape == s,
              onSelected: (_) => chooseShape(s),
            ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, c) => GestureDetector(
            key: const Key('boundary-map'),
            onTapDown: shape != 'Polygon'
                ? null
                : (d) => setState(() {
                    points = [
                      ...points,
                      Offset(
                        (d.localPosition.dx / c.maxWidth).clamp(0, 1),
                        (d.localPosition.dy / 235).clamp(0, 1),
                      ),
                    ];
                    boundaryError = null;
                  }),
            child: SizedBox(
              height: 235,
              width: double.infinity,
              child: FarmArt(map: true, points: points),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Text(
              shape == 'Polygon'
                  ? 'Tap 3 or more corners to draw your field.'
                  : 'A sample $shape boundary is selected.',
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ),
          if (shape == 'Polygon')
            TextButton(
              onPressed: points.isEmpty
                  ? null
                  : () => setState(
                      () => points = points.sublist(0, points.length - 1),
                    ),
              child: const Text('Undo'),
            ),
        ],
      ),
      if (boundaryError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            boundaryError!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      const SizedBox(height: 8),
      Pill(
        '${acres.toStringAsFixed(2)} acres · ${(acres * 4046.8564224).round()} m²',
        icon: Icons.crop_free,
      ),
      const SizedBox(height: 8),
      const Text(
        'Demo area estimate on a 400 × 300 m practice grid. This is not a land measurement.',
        style: TextStyle(fontSize: 10, color: muted),
      ),
      const SizedBox(height: 22),
      Form(
        key: form,
        child: Column(
          children: [
            TextFormField(
              key: const Key('field-name'),
              controller: name,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Field name',
                hintText: 'e.g. South Meadow',
              ),
              validator: (v) => v == null || v.trim().length < 2
                  ? 'Give your field a name of at least 2 characters.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: soil,
              decoration: const InputDecoration(labelText: 'Soil type'),
              items: [
                'Sandy loam',
                'Clay loam',
                'Loam',
                'Sandy',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => soil = v!,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('save-field'),
          onPressed: () {
            final valid = form.currentState!.validate();
            if (points.length < 3 || acres < .01 || !isSimplePolygon(points)) {
              setState(
                () => boundaryError =
                    'Draw a non-crossing boundary with at least 3 corners.',
              );
              return;
            }
            if (!valid) return;
            widget.store.addField(
              FarmField(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name.text.trim(),
                acres: double.parse(acres.toStringAsFixed(2)),
                soil: soil,
                boundary: points.map((p) => [p.dx, p.dy]).toList(),
              ),
            );
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Save field'),
        ),
      ),
    ],
  );
}

double polygonArea(List<Offset> points) {
  if (points.length < 3) return 0;
  double area = 0;
  for (var i = 0; i < points.length; i++) {
    final a = points[i], b = points[(i + 1) % points.length];
    area += a.dx * b.dy - b.dx * a.dy;
  }
  return area.abs() / 2;
}

bool isSimplePolygon(List<Offset> p) {
  if (p.length < 3 || polygonArea(p) < .00001) return false;
  double cross(Offset a, Offset b, Offset c) =>
      (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  bool onSegment(Offset a, Offset b, Offset c) =>
      c.dx >= math.min(a.dx, b.dx) - 1e-9 &&
      c.dx <= math.max(a.dx, b.dx) + 1e-9 &&
      c.dy >= math.min(a.dy, b.dy) - 1e-9 &&
      c.dy <= math.max(a.dy, b.dy) + 1e-9;
  for (var i = 0; i < p.length; i++) {
    if ((p[i] - p[(i + 1) % p.length]).distance < .001) return false;
    for (var j = i + 1; j < p.length; j++) {
      if (j == i + 1 || (i == 0 && j == p.length - 1)) continue;
      final a = p[i],
          b = p[(i + 1) % p.length],
          c = p[j],
          d = p[(j + 1) % p.length];
      final x = cross(a, b, c),
          y = cross(a, b, d),
          z = cross(c, d, a),
          w = cross(c, d, b);
      if ((x * y < 0 && z * w < 0) ||
          (x.abs() < 1e-9 && onSegment(a, b, c)) ||
          (y.abs() < 1e-9 && onSegment(a, b, d)) ||
          (z.abs() < 1e-9 && onSegment(c, d, a)) ||
          (w.abs() < 1e-9 && onSegment(c, d, b))) {
        return false;
      }
    }
  }
  return true;
}

class CycleDialog extends StatefulWidget {
  const CycleDialog({super.key, required this.store, required this.field});
  final FarmStore store;
  final FarmField field;
  @override
  State<CycleDialog> createState() => _CycleDialogState();
}

class _CycleDialogState extends State<CycleDialog> {
  String variety = 'Akbar-2019',
      supplier = 'Punjab Seed Corporation',
      partner = 'FFC';
  DateTime sowing = DateUtils.dateOnly(DateTime.now());
  Widget dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> changed,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => changed(v!)),
    ),
  );
  @override
  Widget build(BuildContext context) => FlowDialog(
    title: 'Every season starts with a seed.',
    eyebrow: 'START A CROP CYCLE',
    children: [
      Pill(
        '${widget.field.name} · ${widget.field.acres} acres',
        icon: Icons.grass,
      ),
      const SizedBox(height: 22),
      dropdown('Wheat variety', variety, [
        'Akbar-2019',
        'Dilkash-20',
        'Fakhr-e-Bhakkar',
        'Subhani-21',
      ], (v) => variety = v),
      dropdown('Seed supplier', supplier, [
        'Punjab Seed Corporation',
        'FFC Seeds',
        'Local certified supplier',
      ], (v) => supplier = v),
      dropdown('Fertilizer partner', partner, [
        'FFC',
        'Engro',
        'Fatima',
        'Other',
      ], (v) => partner = v),
      OutlinedButton(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: sowing,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          if (date != null && mounted) setState(() => sowing = date);
        },
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sown on ${sowing.day}/${sowing.month}/${sowing.year}',
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Your 140-day journal begins on this date. Growth stages will be recorded through observations.',
        style: TextStyle(fontSize: 12, color: muted),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('start-cycle'),
          onPressed: () {
            widget.field.variety = variety;
            widget.field.supplier = supplier;
            widget.field.partner = partner;
            widget.field.sown = sowing;
            widget.field.stage = 0;
            widget.field.observations.add(
              Observation(
                title: 'A new growing season',
                detail: '$variety sown · $supplier · $partner',
                date: sowing,
                kind: 'cycle',
              ),
            );
            widget.store.save();
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.spa_outlined, size: 18),
          label: const Text('Start growing'),
        ),
      ),
    ],
  );
}

class ScanDialog extends StatefulWidget {
  const ScanDialog({super.key, required this.store, required this.field});
  final FarmStore store;
  final FarmField field;
  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  double angle = 62;
  bool scanning = false, result = false;
  bool get ready => angle >= 45 && angle <= 80;
  Future<void> analyze() async {
    setState(() => scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        scanning = false;
        result = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FlowDialog(
    title: result
        ? 'A closer look at your wheat.'
        : 'Let’s see how it’s growing.',
    eyebrow: result ? 'YOUR SAMPLE SCAN RESULT' : 'GUIDED CROP SCAN',
    children: [
      Row(
        children: [
          Expanded(child: Pill(widget.field.name, icon: Icons.grass)),
          const SizedBox(width: 8),
          const Pill('DEMO SCAN', color: amber, background: Color(0xFFF7EFDE)),
        ],
      ),
      const SizedBox(height: 18),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: result ? 170 : 260,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: WheatArt())),
              if (!result)
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .75),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white.withValues(alpha: .8),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Center(
                  child: Pill(
                    result
                        ? 'Sample canopy illustration'
                        : ready
                        ? 'Angle looks good · ${angle.round()}°'
                        : 'Adjust to 45°–80°',
                    background: ready ? lime : const Color(0xFFF7EFDE),
                    icon: ready
                        ? Icons.check_circle_outline
                        : Icons.screen_rotation,
                  ),
                ),
              ),
              if (scanning)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x99000000),
                    child: Center(
                      child: CircularProgressIndicator(color: lime),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      if (!result) ...[
        const Text(
          'Practice the perfect angle',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        const Text(
          'Keep the canopy in frame. Move the demo angle slider into the capture range.',
          style: TextStyle(fontSize: 12, color: muted),
        ),
        Slider(
          value: angle,
          min: 0,
          max: 90,
          divisions: 90,
          label: '${angle.round()}°',
          onChanged: scanning ? null : (v) => setState(() => angle = v),
        ),
        const Text(
          'This preview uses an illustration and a simulated angle. It does not access your camera or run an AI model.',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('analyze-scan'),
            onPressed: ready && !scanning ? analyze : null,
            icon: const Icon(Icons.camera_alt_outlined, size: 19),
            label: Text(
              scanning ? 'Preparing sample result…' : 'Try demo scan',
            ),
          ),
        ),
      ] else ...[
        Surface(
          color: const Color(0xFFF0F4E8),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const IconBox(Icons.spa_outlined, background: lime, size: 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stages[widget.field.stage],
                      style: const TextStyle(
                        fontSize: 24,
                        color: forest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '96% sample confidence',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'A moment to observe',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        const SizedBox(height: 10),
        const Text(
          'Inspect the canopy and note leaf color, growth, and soil conditions. Save this sample observation to try the field journal.',
          style: TextStyle(fontSize: 13, color: muted),
        ),
        const SizedBox(height: 16),
        const Text(
          'Illustrative result only. The stage matches your selected demo field and is not inferred from an image.',
          style: TextStyle(fontSize: 11, color: amber),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('save-scan'),
            onPressed: () {
              widget.store.saveScan(widget.field, widget.field.stage);
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Save to field journal'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() => result = false),
            child: const Text('Try again'),
          ),
        ),
      ],
    ],
  );
}
