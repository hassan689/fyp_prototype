part of 'app.dart';

const growingPlans = [
  (
    'The balanced approach',
    'Akbar-2019',
    '62',
    'Faisalabad',
    'A thoughtful balance of field observations, timely care, and consistent record keeping.',
  ),
  (
    'Small steps, strong roots',
    'Dilkash-20',
    '58',
    'Jhang',
    'A season built around regular canopy checks and careful water management.',
  ),
  (
    'A season of observation',
    'Akbar-2019',
    '60',
    'Toba Tek Singh',
    'A practical field journal that keeps every growth milestone in view.',
  ),
];

extension _Discover on _FarmShellState {
  Widget discoverPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageIntro(
        'KNOWLEDGE GROWS WHEN SHARED',
        tr('Better harvests, together.', 'مل کر بہتر فصل حاصل کریں۔'),
        'Explore growing stories and take a little inspiration back to your field.',
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ChoiceChip(
            label: const Text('Growing plans'),
            selected: !regional,
            onSelected: (_) => refresh(() => regional = false),
          ),
          ChoiceChip(
            label: const Text('Around your farm'),
            selected: regional,
            onSelected: (_) => refresh(() => regional = true),
          ),
        ],
      ),
      const SizedBox(height: 24),
      if (regional)
        regionalMap()
      else ...[
        Surface(
          color: const Color(0xFFEDF1E0),
          child: Row(
            children: [
              const IconBox(
                Icons.workspace_premium_outlined,
                background: lime,
                size: 54,
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn from a season well grown.',
                      style: TextStyle(
                        fontSize: 20,
                        color: forest,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Sample 140-day plans inspired by the idea of shared farming knowledge. Results shown are illustrative.',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: [
            for (final filter in ['All varieties', 'Akbar-2019', 'Dilkash-20'])
              ChoiceChip(
                label: Text(filter),
                selected: discoveryFilter == filter,
                onSelected: (_) => refresh(() => discoveryFilter = filter),
              ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
            final count = c.maxWidth > 950
                ? 3
                : c.maxWidth > 600
                ? 2
                : 1;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (var i = 0; i < growingPlans.length; i++)
                  if (discoveryFilter == 'All varieties' ||
                      growingPlans[i].$2 == discoveryFilter)
                    SizedBox(
                      width: (c.maxWidth - (count - 1) * 20) / count,
                      child: planCard(i),
                    ),
              ],
            );
          },
        ),
      ],
    ],
  );

  Widget planCard(int i) {
    final p = growingPlans[i];
    final adopted = store.plans[field.id] == p.$1;
    return ClipRRect(
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
            SizedBox(
              height: 165,
              child: Stack(
                children: [
                  Positioned.fill(child: FarmArt(variant: i)),
                  const Positioned(
                    top: 15,
                    left: 15,
                    child: Pill(
                      'SAMPLE GROWING STORY',
                      background: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: Pill(
                      '${p.$3} maunds / acre',
                      background: forest,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.$4.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      color: amber,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    p.$1,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.5,
                      color: forest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.$5,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    children: [Pill(p.$2), const Pill('140 days')],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => planDetails(i),
                      icon: Icon(
                        adopted ? Icons.bookmark : Icons.arrow_outward,
                        size: 16,
                      ),
                      label: Text(
                        adopted ? 'Following · view plan' : 'Explore this plan',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> planDetails(int index) async {
    final plan = growingPlans[index];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'A SEASON TO LEARN FROM',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: muted,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  plan.$1,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '${plan.$2} · ${plan.$4} · Sample plan',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 24),
                for (final step in [
                  (
                    '01–20',
                    'Start with the soil',
                    'Record sowing details and check early establishment.',
                  ),
                  (
                    '21–45',
                    'Find a steady rhythm',
                    'Observe tillering and keep a consistent field journal.',
                  ),
                  (
                    '46–75',
                    'Watch the canopy',
                    'Track stem growth and inspect the leaves regularly.',
                  ),
                  (
                    '76–110',
                    'Stay close to your crop',
                    'Record flowering and grain development observations.',
                  ),
                  (
                    '111–140',
                    'Reflect on the season',
                    'Log maturity, harvest outcomes, and lessons learned.',
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 65,
                          child: Text(
                            step.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              color: forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.$3,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Save this reference plan to ${field.name}. It does not change your sowing date or observed growth stage.',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: store.plans[field.id] == plan.$1
                        ? null
                        : () {
                            store.adopt(plan.$1);
                            Navigator.pop(dialogContext);
                            toast('Growing plan saved to ${field.name}');
                          },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: Text(
                      store.plans[field.id] == plan.$1
                          ? 'Already following'
                          : 'Follow this growing plan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget regionalMap() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A glimpse of the growing community',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          color: forest,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Explore anonymous sample fields by growth stage.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 20),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: LayoutBuilder(
          builder: (context, c) => SizedBox(
            height: 440,
            child: Stack(
              children: [
                const Positioned.fill(child: FarmArt(map: true)),
                const Positioned(
                  top: 20,
                  left: 20,
                  child: Pill(
                    'ILLUSTRATED REGIONAL MAP',
                    background: Colors.white,
                    icon: Icons.public,
                  ),
                ),
                for (var i = 0; i < 4; i++)
                  Positioned(
                    left: c.maxWidth * (i % 2 == 0 ? 0.08 : 0.52),
                    top: 95.0 + (i ~/ 2) * 140,
                    child: ActionChip(
                      backgroundColor: [
                        lime,
                        const Color(0xFFDFD9BF),
                        Colors.white,
                        const Color(0xFFD3E4DF),
                      ][i],
                      avatar: const Icon(Icons.grass, size: 18),
                      label: Text(
                        'Plot ${i + 1} · ${stages[i + 1]}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Community plot ${i + 1}'),
                          content: Text(
                            'Stage: ${stages[i + 1]}\nArea: ${3 + i} acres\nDistrict: Faisalabad\n\nIllustrative, anonymous field data. No personal information is shared.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Pill(
                    'Sample locations · no live regional data',
                    background: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
