import 'package:flutter/material.dart';

import 'design.dart';
import 'store.dart';
import 'workflows.dart';

part 'dashboard.dart';
part 'fields.dart';
part 'discover.dart';

class YieldApp extends StatelessWidget {
  const YieldApp({super.key, required this.store});
  final FarmStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'NextGenYield',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(store.largeText ? 1.15 : 1)),
        child: child!,
      ),
      home: FarmShell(store: store),
    ),
  );
}

class FarmShell extends StatefulWidget {
  const FarmShell({super.key, required this.store});
  final FarmStore store;
  @override
  State<FarmShell> createState() => _FarmShellState();
}

class _FarmShellState extends State<FarmShell> {
  int tab = 0;
  bool showTimeline = false;
  String timelineFilter = 'All activity';
  String discoveryFilter = 'All varieties';
  bool regional = false;
  final scroll = ScrollController();
  FarmStore get store => widget.store;
  void refresh(VoidCallback change) => setState(change);
  FarmField get field => store.field;
  bool get urdu => store.language == 'اردو';
  String tr(String en, String ur) => urdu ? ur : en;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void navigate(int index) {
    if (index == 2) {
      scan();
      return;
    }
    setState(() {
      tab = index;
      showTimeline = false;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void toast(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
  Future<void> scan() async {
    if (!field.active) {
      await cycle();
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ScanDialog(store: store, field: field),
    );
    if (saved == true && mounted) toast('Observation saved to ${field.name}');
  }

  Future<void> addField() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddFieldDialog(store: store),
    );
    if (added == true && mounted) {
      navigate(1);
      toast('Your new field is ready. Start a crop cycle when you sow.');
    }
  }

  Future<void> cycle() async {
    final started = await showDialog<bool>(
      context: context,
      builder: (_) => CycleDialog(store: store, field: field),
    );
    if (started == true && mounted) {
      toast('Crop cycle started for ${field.name}');
    }
  }

  void timeline() {
    setState(() {
      tab = 1;
      showTimeline = true;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return PopScope<void>(
      canPop: tab == 0 && !showTimeline,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (showTimeline) {
          setState(() => showTimeline = false);
        } else {
          navigate(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (wide) sidebar(),
              Expanded(
                child: Column(
                  children: [
                    topbar(wide),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scroll,
                        padding: EdgeInsets.all(wide ? 36 : 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1250),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (store.storageError != null) ...[
                                  Surface(
                                    color: const Color(0xFFFFF0D9),
                                    child: Text(store.storageError!),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                switch (tab) {
                                  0 => dashboard(),
                                  1 =>
                                    showTimeline
                                        ? timelinePage()
                                        : fieldsPage(),
                                  3 => discoverPage(),
                                  _ => profilePage(),
                                },
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.eco_outlined,
                                      size: 14,
                                      color: muted,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        tr(
                                          'A little insight. A better harvest.',
                                          'بہتر معلومات، بہتر فصل۔',
                                        ),
                                        style: const TextStyle(
                                          color: muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                height: 76,
                backgroundColor: Colors.white,
                indicatorColor: lime,
                selectedIndex: tab,
                onDestinationSelected: navigate,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_rounded),
                    label: tr('Home', 'ہوم'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.landscape_outlined),
                    label: tr('Fields', 'کھیت'),
                  ),
                  NavigationDestination(
                    icon: const IconBox(
                      Icons.document_scanner_outlined,
                      color: Colors.white,
                      background: forest,
                      size: 42,
                    ),
                    label: tr('Scan', 'اسکین'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.explore_outlined),
                    label: tr('Discover', 'دریافت'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    label: tr('Profile', 'پروفائل'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget brand() => SizedBox(
    width: 193,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconBox(
            Icons.spa_rounded,
            color: lime,
            background: forest,
            size: 40,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NextGenYield',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.6,
                  color: forest,
                ),
              ),
              Text(
                'GROW WITH CONFIDENCE',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.6,
                  color: forest.withValues(alpha: .65),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget sidebar() => Container(
    width: 238,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: line)),
    ),
    padding: const EdgeInsets.fromLTRB(22, 32, 22, 22),
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand(),
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.only(left: 14, bottom: 14),
                  child: Text(
                    'YOUR FARM SPACE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final item in [
                  (0, Icons.grid_view_rounded, tr('Overview', 'جائزہ')),
                  (1, Icons.landscape_outlined, tr('My fields', 'میرے کھیت')),
                  (
                    2,
                    Icons.document_scanner_outlined,
                    tr('Crop scan', 'فصل اسکین'),
                  ),
                  (3, Icons.explore_outlined, tr('Discover', 'دریافت')),
                  (
                    4,
                    Icons.person_outline_rounded,
                    tr('My profile', 'میرا پروفائل'),
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: tab == item.$1
                          ? const Color(0xFFEDF2E6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Icon(
                          item.$2,
                          size: 21,
                          color: tab == item.$1 ? forest : muted,
                        ),
                        title: Text(
                          item.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: tab == item.$1
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: tab == item.$1 ? forest : muted,
                          ),
                        ),
                        onTap: () => navigate(item.$1),
                      ),
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: canvas,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: amber),
                      const SizedBox(height: 12),
                      const Text(
                        'Good things take growing.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: forest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Stay close to your fields, one observation at a time.',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: scan,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Check your crop  ↗'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Divider(),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: lime,
                      child: Text(
                        'AR',
                        style: TextStyle(
                          color: forest,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ahmed Raza',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Demo farm · Faisalabad',
                            style: TextStyle(fontSize: 10, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget topbar(bool wide) => Container(
    padding: EdgeInsets.symmetric(horizontal: wide ? 36 : 20, vertical: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        if (!wide)
          brand()
        else
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 18, color: amber),
              const SizedBox(width: 9),
              Text(
                tr('A new day to grow', 'بڑھنے کا ایک نیا دن'),
                style: const TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
        const Spacer(),
        if (wide) ...[
          const Pill('LOCAL DEMO', icon: Icons.circle_outlined),
          const SizedBox(width: 20),
          const Icon(Icons.location_on_outlined, size: 16, color: muted),
          const SizedBox(width: 5),
          const Text(
            'Faisalabad, Punjab',
            style: TextStyle(fontSize: 12, color: muted),
          ),
          const SizedBox(width: 18),
        ],
        IconButton(
          tooltip: 'Today’s reminders',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Your field reminders'),
              content: const Text(
                'Check the crop canopy and inspect soil moisture today.\n\nThese are sample reminders for your demo farm.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
          icon: const Badge(
            smallSize: 6,
            backgroundColor: amber,
            child: Icon(
              Icons.notifications_none_rounded,
              color: forest,
              size: 23,
            ),
          ),
        ),
      ],
    ),
  );

  Widget pageIntro(
    String eyebrow,
    String title,
    String subtitle, {
    Widget? action,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: LayoutBuilder(
      builder: (context, c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: muted,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: c.maxWidth > 650
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              if (action != null && c.maxWidth > 650) action,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
          ),
          if (action != null && c.maxWidth <= 650) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    ),
  );

  Widget fieldSelector() => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: store.fields.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        if (i == store.fields.length) {
          return IconButton.outlined(
            tooltip: 'Add field',
            onPressed: addField,
            icon: const Icon(Icons.add, size: 20),
          );
        }
        final f = store.fields[i], selected = store.selected == i;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => store.selectField(i),
          showCheckmark: false,
          selectedColor: forest,
          backgroundColor: Colors.white,
          side: BorderSide(color: selected ? forest : line),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grass, size: 16, color: selected ? lime : muted),
              const SizedBox(width: 7),
              Text(
                f.name,
                style: TextStyle(
                  color: selected ? Colors.white : muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget profilePage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageIntro(
        'MAKE IT YOURS',
        tr('Your farm, your way.', 'آپ کا کھیت، آپ کا انداز۔'),
        'A comfortable space for a better growing season.',
      ),
      Surface(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: lime,
              child: Text(
                'AR',
                style: TextStyle(
                  fontSize: 22,
                  color: forest,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ahmed Raza',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Faisalabad, Punjab · Demo farmer',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${store.fields.length} fields · ${store.totalAcres.toStringAsFixed(1)} acres',
                    style: const TextStyle(fontSize: 12, color: forest),
                  ),
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
            SectionHeading(tr('Preferences', 'ترجیحات')),
            Text(
              tr('Navigation language', 'نیویگیشن کی زبان'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Core navigation and overview labels. Sample journal content is in English.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'English', label: Text('English')),
                ButtonSegment(value: 'اردو', label: Text('اردو')),
              ],
              selected: {store.language},
              onSelectionChanged: (s) {
                store.language = s.first;
                store.save();
              },
            ),
            const SizedBox(height: 22),
            const Divider(),
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('Larger text', 'بڑا متن')),
                subtitle: const Text(
                  'More comfortable reading in the field',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                value: store.largeText,
                onChanged: (v) {
                  store.largeText = v;
                  store.save();
                },
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
            const SectionHeading('About this prototype'),
            const Text(
              'NextGenYield',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'A working Flutter experience for monitoring wheat, keeping a field journal, and learning from other growing plans. Your changes are stored on this device.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            const Pill('PROTOTYPE · VERSION 1.0', icon: Icons.science_outlined),
            const SizedBox(height: 14),
            const Text(
              'Scans, weather, regional fields, and growing advice use illustrative sample data. Camera capture, AI inference, satellite maps, voice narration, and cloud synchronization are integration steps for the full app.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.6),
            ),
          ],
        ),
      ),
    ],
  );
}
