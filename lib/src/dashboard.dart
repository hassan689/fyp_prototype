part of 'app.dart';

extension _Dashboard on _FarmShellState {
  Widget dashboard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageIntro(
        tr('YOUR DAILY FIELD NOTES', 'آپ کے روزانہ کھیت کے نوٹس'),
        tr('Good things are growing.', 'آپ کی فصل بڑھ رہی ہے۔'),
        tr(
          'Welcome back, Ahmed. Let’s make this a good growing day.',
          'خوش آمدید احمد۔ آئیے آج اپنی فصل کا خیال رکھیں۔',
        ),
        action: OutlinedButton.icon(
          onPressed: addField,
          icon: const Icon(Icons.add, size: 17),
          label: Text(tr('Add a field', 'کھیت شامل کریں')),
        ),
      ),
      LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 760;
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: overviewMain()),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: overviewAside()),
                  ],
                )
              : Column(
                  children: [
                    overviewMain(),
                    const SizedBox(height: 24),
                    overviewAside(),
                  ],
                );
        },
      ),
    ],
  );

  Widget overviewMain() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      hero(),
      const SizedBox(height: 26),
      fieldSelector(),
      const SizedBox(height: 18),
      growthCard(),
      const SizedBox(height: 26),
      SectionHeading(
        tr('A little care, a big difference', 'تھوڑی سی دیکھ بھال، بڑا فرق'),
        action: tr('Field journal', 'کھیت کی ڈائری'),
        onTap: timeline,
      ),
      if (field.active) ...[
        taskCard(
          'moisture',
          Icons.water_drop_outlined,
          'Check soil moisture',
          'Take a look before your next watering.',
          'TODAY',
          const Color(0xFFEAF1F5),
          const Color(0xFF46718B),
        ),
        const SizedBox(height: 10),
        taskCard(
          'canopy',
          Icons.eco_outlined,
          'Walk your wheat canopy',
          'Look closely at leaf color and new growth.',
          'FIELD CHECK',
          const Color(0xFFF2F1E5),
          amber,
        ),
      ] else
        Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A new season starts here.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your sowing date to begin tracking this field.',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: cycle,
                child: const Text('Start crop cycle'),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      const Text(
        'Sample care reminders for this prototype.',
        style: TextStyle(fontSize: 11, color: muted),
      ),
    ],
  );

  Widget hero() => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Container(
      width: double.infinity,
      color: forest,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: c.maxWidth * .47,
              child: const Opacity(opacity: .9, child: FarmArt()),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [forest, forest, forest.withValues(alpha: 0)],
                    stops: const [0, .35, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Pill(
                    'ROOTED IN BETTER GROWING',
                    color: lime,
                    background: Color(0xFF3A5D49),
                    icon: Icons.spa_outlined,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    tr(
                      'Know your crop.\nGrow with confidence.',
                      'اپنی فصل کو جانیں۔\nاعتماد سے اگائیں۔',
                    ),
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: c.maxWidth * .68),
                    child: Text(
                      tr(
                        'One simple scan. A clearer picture of your wheat’s next chapter.',
                        'ایک آسان اسکین۔ اپنی گندم کی نشوونما کو سمجھیں۔',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD4DFD1),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: scan,
                    style: FilledButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: forest,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.document_scanner_outlined, size: 18),
                    label: Text(tr('Scan your crop', 'فصل اسکین کریں')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget growthCard() => Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('YOUR CROP AT A GLANCE', 'آپ کی فصل ایک نظر میں'),
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.4,
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    field.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Pill(
              field.active ? 'Day ${field.day} / 140' : 'Ready to sow',
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const IconBox(Icons.grass_rounded, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.active ? stages[field.stage] : 'A fresh beginning',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: forest,
                      letterSpacing: -.5,
                    ),
                  ),
                  Text(
                    field.active
                        ? '${field.variety} · ${field.acres} acres'
                        : 'No active crop cycle',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            if (field.active)
              const Pill('Active', icon: Icons.circle, color: forest),
          ],
        ),
        const SizedBox(height: 24),
        if (field.active) ...[
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= field.stage ? forest : line,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                if (i < 5) const SizedBox(width: 5),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 6,
              children: [
                const Text(
                  'Tillering',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
                Text(
                  'Stage ${field.stage + 1} of 6',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: forest,
                  ),
                ),
                const Text(
                  'Maturity',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          TextButton(
            onPressed: timeline,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tr('Explore your crop journey', 'فصل کا سفر دیکھیں'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 17),
              ],
            ),
          ),
        ] else
          FilledButton(onPressed: cycle, child: const Text('Start crop cycle')),
      ],
    ),
  );

  Widget taskCard(
    String id,
    IconData icon,
    String title,
    String subtitle,
    String label,
    Color bg,
    Color fg,
  ) {
    final done = store.completed.contains('${field.id}:$id');
    return Surface(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          IconBox(icon, background: bg, color: fg),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? 'COMPLETED' : label,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: done ? forest : fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: done ? muted : ink,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Checkbox(
            value: done,
            onChanged: (_) => store.toggleTask(id, title),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            semanticLabel: 'Complete $title',
          ),
        ],
      ),
    );
  }

  Widget overviewAside() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Surface(
        color: const Color(0xFFF0F2E7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 15, color: muted),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Faisalabad, Punjab',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
                const Text(
                  'SAMPLE',
                  style: TextStyle(fontSize: 8, letterSpacing: 1, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24°',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -3,
                          color: forest,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'A little sunshine.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Clear skies · Feels like 26°',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.wb_sunny_rounded,
                  size: 66,
                  color: const Color(0xFFD3AD59).withValues(alpha: .85),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: WeatherMetric(
                    Icons.water_drop_outlined,
                    '12%',
                    'Rain chance',
                  ),
                ),
                Expanded(
                  child: WeatherMetric(Icons.air_rounded, '8 km/h', 'Wind'),
                ),
                Expanded(
                  child: WeatherMetric(Icons.waves_rounded, '58%', 'Humidity'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(tr('Your farm, in numbers', 'آپ کے کھیت کے اعداد')),
            Row(
              children: [
                Expanded(
                  child: stat(
                    store.fields
                        .where((f) => f.active)
                        .length
                        .toString()
                        .padLeft(2, '0'),
                    'Active fields',
                    Icons.grass,
                  ),
                ),
                Expanded(
                  child: stat(
                    store.totalAcres.toStringAsFixed(1),
                    'Total acres',
                    Icons.crop_free,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.bookmark_border_rounded,
                  size: 18,
                  color: forest,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    store.plans[field.id] ??
                        'A growing season full of possibility.',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 125,
                width: double.infinity,
                child: FarmArt(variant: 2),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GROW TOGETHER',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.8,
                        color: amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Great harvests start\nwith shared knowledge.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: forest,
                        height: 1.25,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Explore the habits behind a thriving wheat field.',
                      style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => navigate(3),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Explore growing plans',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_outward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  Widget stat(String number, String label, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: muted, size: 18),
      const SizedBox(height: 12),
      Text(
        number,
        style: const TextStyle(
          fontSize: 31,
          color: forest,
          letterSpacing: -1,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: muted)),
    ],
  );
}

class WeatherMetric extends StatelessWidget {
  const WeatherMetric(this.icon, this.value, this.label, {super.key});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: muted),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 9, color: muted)),
    ],
  );
}
