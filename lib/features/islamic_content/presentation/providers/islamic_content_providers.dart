import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/islamhouse_content_type.dart';
import '../../data/models/islamhouse_item.dart';
import '../../data/repositories/islamhouse_repository.dart';

final islamhouseRepositoryProvider = Provider<IslamhouseRepository>((ref) {
  return IslamhouseRepository();
});

final islamhouseTypesProvider = FutureProvider<List<IslamhouseContentType>>((
  ref,
) {
  return ref
      .read(islamhouseRepositoryProvider)
      .fetchTypes()
      .then(
        (types) => types.where((t) => t.isBrowsable).toList(growable: false),
      );
});

final islamhouseHighlightsProvider = FutureProvider<List<IslamhouseItem>>((
  ref,
) {
  return ref
      .read(islamhouseRepositoryProvider)
      .fetchHighlights(limit: 16)
      .then((items) => items.take(10).toList(growable: false));
});

final islamhouseLatestProvider = FutureProvider<List<IslamhouseItem>>((ref) {
  return ref
      .read(islamhouseRepositoryProvider)
      .fetchLatestItems(page: 1, limit: 12)
      .then((value) => value.items);
});

final islamhouseItemDetailsProvider =
    FutureProvider.family<IslamhouseItem, int>((ref, itemId) {
      return ref
          .read(islamhouseRepositoryProvider)
          .fetchItemDetails(itemId: itemId);
    });
