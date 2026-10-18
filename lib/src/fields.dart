part of 'app.dart';

extension _Fields on _FarmShellState {
  Widget fieldsPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageIntro(
        'A PLACE FOR EVERY PLOT',
        tr('Small fields. Big possibilities.', 'چھوٹے کھیت۔ بڑے امکانات۔'),
        '${store.fields.length} fields · ${store.totalAcres.toStringAsFixed(1)} acres of possibility',
        action: FilledButton.icon(
          onPressed: addField,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add a field'),
        ),
      ),
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
              for (var i = 0; i < store.fields.length; i++)
                SizedBox(
                  width: (c.maxWidth - (count - 1) * 20) / count,
                  child: fieldCard(i),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 30),
      const SectionHeading('Your corner of the world'),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 320,
          child: Stack(
            children: [
              const Positioned.fill(child: FarmArt(map: true)),
              const Positioned(
                top: 18,
                left: 18,
                child: Pill(
                  'ILLUSTRATED FARM MAP',
                  background: Colors.white,
                  icon: Icons.map_outlined,
                ),
              ),
              for (var i = 0; i < store.fields.length.clamp(0, 5); i++)
                Positioned(
                  left: 24.0 + (i % 3) * 90,
                  top: 80.0 + (i % 2) * 90,
                  child: ActionChip(
                    avatar: Icon(
                      Icons.location_on,
                      size: 18,
                      color: store.selected == i ? forest : muted,
                    ),
                    label: Text(
                      store.fields[i].name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: store.selected == i ? lime : Colors.white,
                    onPressed: () {
                      store.selectField(i);
                      timeline();
                    },
                  ),
                ),
              const Positioned(
                bottom: 16,
                left: 18,
                right: 18,
                child: Text(
                  'Schematic preview · not actual field locations',
                  style: TextStyle(fontSize: 11, color: forest),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget fieldCard(int index) {
    final f = store.fields[index];
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
              height: 155,
              child: Stack(
                children: [
                  Positioned.fill(child: FarmArt(variant: index)),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Pill(
                      f.active ? stages[f.stage] : 'Ready to sow',
                      background: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Pill(
                      '${f.acres} acres',
                      color: Colors.white,
                      background: forest,
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
                  Text(f.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text(
                    '${f.variety} · ${f.soil}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  if (f.active) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Growing season',
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                        Text(
                          'Day ${f.day} / 140',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (f.day / 140).clamp(0, 1),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(5),
                      backgroundColor: line,
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        store.selectField(index);
                        if (f.active) {
                          timeline();
                        } else {
                          cycle();
                        }
                      },
                      label: Text(
                        f.active ? 'View field journal' : 'Start crop cycle',
                      ),
                      icon: Icon(
                        f.active ? Icons.arrow_forward : Icons.add,
                        size: 17,
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

  Widget timelinePage() {
    final events = field.observations
        .where(
          (o) =>
              timelineFilter == 'All activity' ||
              (timelineFilter == 'Scans' && o.kind == 'scan') ||
              (timelineFilter == 'Care log' && o.kind != 'scan'),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => refresh(() => showTimeline = false),
          icon: const Icon(Icons.arrow_back, size: 17),
          label: const Text('All fields'),
        ),
        const SizedBox(height: 12),
        pageIntro(
          'EVERY STAGE TELLS A STORY',
          field.name,
          '${field.variety} · ${field.acres} acres · ${field.soil}',
          action: FilledButton.icon(
            onPressed: scan,
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: const Text('New observation'),
          ),
        ),
        fieldSelector(),
        const SizedBox(height: 24),
        if (!field.active)
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This field is ready for a new season.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: cycle,
                  child: const Text('Start crop cycle'),
                ),
              ],
            ),
          )
        else ...[
          growthCard(),
          const SizedBox(height: 24),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading('The growing journey'),
                for (var i = 0; i < stages.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: i <= field.stage ? forest : canvas,
                            shape: BoxShape.circle,
                            border: Border.all(color: line),
                          ),
                          child: Icon(
                            i < field.stage
                                ? Icons.check
                                : i == field.stage
                                ? Icons.spa_outlined
                                : Icons.circle_outlined,
                            size: 16,
                            color: i <= field.stage ? lime : muted,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stages[i],
                                style: TextStyle(
                                  fontWeight: i == field.stage
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: i > field.stage ? muted : ink,
                                ),
                              ),
                              Text(
                                [
                                  'New shoots establish the foundation.',
                                  'Stems lengthen and the canopy develops.',
                                  'The wheat head develops within the leaf sheath.',
                                  'Flowering begins across the wheat heads.',
                                  'Grain develops and gradually fills.',
                                  'The crop reaches the final chapter.',
                                ][i],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i == field.stage) const Pill('Current'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading('Season details'),
                Wrap(
                  spacing: 35,
                  runSpacing: 20,
                  children: [
                    detail('Sowing date', dateLabel(field.sown!)),
                    detail('Seed variety', field.variety),
                    detail('Seed supplier', field.supplier),
                    detail('Fertilizer partner', field.partner),
                    detail(
                      'Growing plan',
                      store.plans[field.id] ?? 'Your own approach',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 30),
        const SectionHeading('Your field journal'),
        Wrap(
          spacing: 8,
          children: [
            for (final filter in ['All activity', 'Scans', 'Care log'])
              ChoiceChip(
                label: Text(filter),
                selected: timelineFilter == filter,
                onSelected: (_) => refresh(() => timelineFilter = filter),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (events.isEmpty)
          const Surface(
            child: Row(
              children: [
                IconBox(Icons.auto_stories_outlined),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Your story starts here. Save a scan or complete a field check to add an entry.',
                    style: TextStyle(color: muted),
                  ),
                ),
              ],
            ),
          )
        else ...[
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Surface(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBox(
                      event.kind == 'scan'
                          ? Icons.document_scanner_outlined
                          : event.kind == 'plan'
                          ? Icons.bookmark_outline
                          : Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.detail,
                            style: const TextStyle(fontSize: 12, color: muted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateLabel(event.date),
                            style: const TextStyle(fontSize: 10, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget detail(String label, String value) => SizedBox(
    width: 185,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

String dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
