import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const stages = [
  'Tillering',
  'Jointing',
  'Booting',
  'Anthesis',
  'Grain filling',
  'Maturity',
];

class Observation {
  Observation({
    required this.title,
    required this.detail,
    required this.date,
    this.kind = 'scan',
  });
  final String title;
  final String detail;
  final DateTime date;
  final String kind;
  Map<String, dynamic> toJson() => {
    'title': title,
    'detail': detail,
    'date': date.toIso8601String(),
    'kind': kind,
  };
  factory Observation.fromJson(Map<String, dynamic> j) => Observation(
    title: j['title'],
    detail: j['detail'],
    date: DateTime.parse(j['date']),
    kind: j['kind'],
  );
}

class FarmField {
  FarmField({
    required this.id,
    required this.name,
    required this.acres,
    this.variety = 'Akbar-2019',
    this.soil = 'Sandy loam',
    this.partner = 'FFC',
    this.supplier = 'Punjab Seed Corporation',
    this.sown,
    this.stage = 0,
    List<Observation>? observations,
    List<List<double>>? boundary,
  }) : observations = observations ?? [],
       boundary = boundary ?? [];
  final String id;
  final String name;
  final double acres;
  String variety;
  String soil;
  String partner;
  String supplier;
  DateTime? sown;
  int stage;
  final List<Observation> observations;
  final List<List<double>> boundary;
  bool get active => sown != null;
  int get day =>
      sown == null ? 0 : DateTime.now().difference(sown!).inDays.clamp(0, 999);
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'acres': acres,
    'variety': variety,
    'soil': soil,
    'partner': partner,
    'supplier': supplier,
    'sown': sown?.toIso8601String(),
    'stage': stage,
    'observations': observations.map((e) => e.toJson()).toList(),
    'boundary': boundary,
  };
  factory FarmField.fromJson(Map<String, dynamic> j) => FarmField(
    id: j['id'],
    name: j['name'],
    acres: (j['acres'] as num).toDouble(),
    variety: j['variety'],
    soil: j['soil'],
    partner: j['partner'],
    supplier: j['supplier'] ?? 'Punjab Seed Corporation',
    sown: j['sown'] == null ? null : DateTime.parse(j['sown']),
    stage: j['stage'],
    observations: (j['observations'] as List)
        .map((e) => Observation.fromJson(e))
        .toList(),
    boundary: (j['boundary'] as List? ?? [])
        .map((e) => (e as List).map((n) => (n as num).toDouble()).toList())
        .toList(),
  );
}

class FarmStore extends ChangeNotifier {
  List<FarmField> fields = [];
  int selected = 0;
  bool largeText = false;
  String language = 'English';
  Set<String> completed = {};
  Map<String, String> plans = {};
  String? storageError;
  FarmField get field => fields[selected.clamp(0, fields.length - 1)];
  double get totalAcres => fields.fold(0, (sum, f) => sum + f.acres);

  void seed() {
    final now = DateTime.now();
    fields = [
      FarmField(
        id: 'north',
        name: 'North Canal',
        acres: 4.2,
        stage: 2,
        sown: now.subtract(const Duration(days: 74)),
        observations: [
          Observation(
            title: 'Booting stage observed',
            detail: 'Demo scan · 96% confidence',
            date: now.subtract(const Duration(days: 2)),
          ),
          Observation(
            title: 'Irrigation completed',
            detail: 'Watering recorded for North Canal',
            date: now.subtract(const Duration(days: 6)),
            kind: 'water',
          ),
          Observation(
            title: 'Jointing stage observed',
            detail: 'Demo scan · 94% confidence',
            date: now.subtract(const Duration(days: 24)),
          ),
        ],
      ),
      FarmField(
        id: 'east',
        name: 'East Meadow',
        acres: 3.6,
        variety: 'Dilkash-20',
        stage: 1,
        sown: now.subtract(const Duration(days: 49)),
      ),
      FarmField(id: 'orchard', name: 'Orchard Side', acres: 2.4),
    ];
  }

  Future<void> load() async {
    seed();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('nextgenyield.v1');
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final saved = (data['fields'] as List)
          .map((e) => FarmField.fromJson(e))
          .toList();
      if (saved.isNotEmpty) fields = saved;
      selected = (data['selected'] as int? ?? 0).clamp(0, fields.length - 1);
      largeText = data['largeText'] ?? false;
      language = data['language'] ?? 'English';
      completed = Set<String>.from(data['completed'] ?? []);
      plans = Map<String, String>.from(data['plans'] ?? {});
    } catch (_) {
      storageError =
          'Saved data could not be loaded. A fresh demo is available.';
    }
  }

  Future<void> save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(
        'nextgenyield.v1',
        jsonEncode({
          'fields': fields.map((f) => f.toJson()).toList(),
          'selected': selected,
          'largeText': largeText,
          'language': language,
          'completed': completed.toList(),
          'plans': plans,
        }),
      );
      if (!ok) throw StateError('Could not save');
      storageError = null;
    } catch (_) {
      storageError = 'Changes are available this session, but could not be saved to this device.';
    }
    notifyListeners();
  }

  void selectField(int i) {
    selected = i;
    save();
  }

  void addField(FarmField f) {
    fields.add(f);
    selected = fields.length - 1;
    save();
  }

  void toggleTask(String id, String title) {
    final key = '${field.id}:$id';
    if (completed.contains(key)) {
      completed.remove(key);
      field.observations.removeWhere((e) => e.kind == 'task:$id');
    } else {
      completed.add(key);
      field.observations.insert(
        0,
        Observation(
          title: title,
          detail: 'Marked complete in your field journal',
          date: DateTime.now(),
          kind: 'task:$id',
        ),
      );
    }
    save();
  }

  void saveScan(FarmField target, int stage) {
    target.stage = stage;
    target.observations.insert(
      0,
      Observation(
        title: '${stages[stage]} stage observed',
        detail: 'Demo scan · 96% confidence · sample result',
        date: DateTime.now(),
      ),
    );
    save();
  }

  void adopt(String name) {
    plans[field.id] = name;
    field.observations.insert(
      0,
      Observation(
        title: 'Growing plan followed',
        detail: name,
        date: DateTime.now(),
        kind: 'plan',
      ),
    );
    save();
  }
}
