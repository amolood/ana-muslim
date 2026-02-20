import 'package:muslim_data_flutter/muslim_data_flutter.dart' as mdfl;

import '../models/azkar_model.dart';

/// Single source of truth for Azkar data, backed by [mdfl.MuslimRepository].
///
/// Maps [mdfl.AzkarChapter] → our [AzkarCategoryEntry] (category display)
/// Maps [mdfl.AzkarItem]    → our [AzkarItem]           (dhikr card)
class AzkarRepository {
  AzkarRepository._();

  static final AzkarRepository instance = AzkarRepository._();

  late final mdfl.MuslimRepository _repo;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _repo = mdfl.MuslimRepository();
    _ready = true;
  }

  /// Returns all chapters (displayed as category cards) in Arabic.
  Future<List<AzkarCategoryEntry>> getCategories() async {
    await init();
    final chapters = await _repo.getAzkarChapters(
      language: mdfl.Language.ar,
      categoryId: -1, // all categories
    );
    final seen = <int>{};
    final entries = <AzkarCategoryEntry>[];
    for (final ch in chapters) {
      if (seen.contains(ch.id)) continue;
      seen.add(ch.id);
      entries.add(AzkarCategoryEntry(id: ch.id, name: ch.name));
    }
    return entries;
  }

  /// Returns dhikr items for the given chapter [id].
  Future<List<AzkarItem>> getItemsByChapterId(int id) async {
    await init();
    final rawItems = await _repo.getAzkarItems(
      language: mdfl.Language.ar,
      chapterId: id,
    );
    return rawItems
        .map(
          (it) => AzkarItem(
            id: it.id,
            category: '',       // filled by caller if needed
            zekr: it.item,
            description: it.translation,
            count: 1,           // muslim_data_flutter doesn't expose count
            reference: it.reference,
            search: it.item,
          ),
        )
        .toList();
  }

  /// Returns the 99 names of Allah in Arabic.
  Future<List<AsmaEntry>> getAsmaAllah() async {
    await init();
    final names = await _repo.getNames(language: mdfl.Language.ar);
    return names
        .map((n) => AsmaEntry(
              id: n.id,
              name: n.name,
              meaning: n.translation,
            ))
        .toList();
  }
}

/// Thin model for a category entry (wraps AzkarChapter).
class AzkarCategoryEntry {
  final int id;
  final String name;

  const AzkarCategoryEntry({required this.id, required this.name});
}

/// Thin model for one of the 99 names of Allah.
class AsmaEntry {
  final int id;
  final String name;
  final String meaning;

  const AsmaEntry({
    required this.id,
    required this.name,
    required this.meaning,
  });
}
