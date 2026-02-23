import 'islamhouse_attachment.dart';

class IslamhouseContributor {
  final int id;
  final String title;
  final String kind;

  const IslamhouseContributor({
    required this.id,
    required this.title,
    required this.kind,
  });

  factory IslamhouseContributor.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic raw) {
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }

    return IslamhouseContributor(
      id: parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      kind: (json['kind'] ?? json['type'] ?? '').toString(),
    );
  }
}

class IslamhouseItem {
  final int id;
  final int sourceId;
  final String title;
  final String type;
  final int addDate;
  final String? description;
  final String? fullDescription;
  final String? content;
  final String? image;
  final String? sourceLanguage;
  final String? translatedLanguage;
  final List<IslamhouseContributor> contributors;
  final List<IslamhouseAttachment> attachments;

  IslamhouseItem({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.type,
    required this.addDate,
    required this.description,
    required this.fullDescription,
    required this.content,
    required this.image,
    required this.sourceLanguage,
    required this.translatedLanguage,
    required this.contributors,
    required this.attachments,
  });

  static const Set<String> hiddenBrowseTypes = <String>{
    'quran',
    'poster',
    'apps',
    'favorites',
    'favourites',
    'favorite',
    'selected',
    'مختارات',
  };

  static const Set<String> _mediaItemTypes = <String>{
    'videos',
    'video',
    'audios',
    'audio',
    'khotab',
    'khotba',
    'khotbah',
    'khutbah',
  };

  static String normalizeTypeKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  static int _parseInt(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String? _parseNullableString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty || value == 'null') return null;
    return value;
  }

  static String? _parseRichText(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      return _parseNullableString(raw);
    }
    if (raw is List) {
      final pieces = raw
          .map(_parseRichText)
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList(growable: false);
      if (pieces.isEmpty) return null;
      return pieces.join('\n');
    }
    if (raw is Map) {
      // Common API shapes: {"ar": "..."} or {"text": "..."}.
      for (final key in const ['ar', 'text', 'content', 'body', 'value']) {
        final parsed = _parseRichText(raw[key]);
        if (parsed != null && parsed.trim().isNotEmpty) {
          return parsed;
        }
      }
      for (final value in raw.values) {
        final parsed = _parseRichText(value);
        if (parsed != null && parsed.trim().isNotEmpty) {
          return parsed;
        }
      }
    }
    return _parseNullableString(raw);
  }

  static bool _isHttpUrl(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static String? _parseHttpUrl(dynamic raw) {
    final value = _parseNullableString(raw);
    if (value == null) return null;
    if (!_isHttpUrl(value)) return null;
    return value;
  }

  static List<IslamhouseAttachment> _parseAttachments(dynamic raw) {
    final list = <IslamhouseAttachment>[];

    if (raw is Map<String, dynamic>) {
      if ((raw['url'] ?? '').toString().trim().isNotEmpty) {
        final item = IslamhouseAttachment.fromJson(raw);
        if (item.hasUrl && _isHttpUrl(item.url)) list.add(item);
      } else {
        for (final value in raw.values) {
          if (value is Map<String, dynamic>) {
            final item = IslamhouseAttachment.fromJson(value);
            if (item.hasUrl && _isHttpUrl(item.url)) list.add(item);
          } else if (value is String && value.trim().isNotEmpty) {
            if (!_isHttpUrl(value)) {
              continue;
            }
            list.add(
              IslamhouseAttachment(
                url: value,
                description: '',
                extensionType: '',
                size: '',
              ),
            );
          }
        }
      }
      return list;
    }

    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          final item = IslamhouseAttachment.fromJson(entry);
          if (item.hasUrl && _isHttpUrl(item.url)) list.add(item);
        } else if (entry is String && entry.trim().isNotEmpty) {
          if (!_isHttpUrl(entry)) {
            continue;
          }
          list.add(
            IslamhouseAttachment(
              url: entry,
              description: '',
              extensionType: '',
              size: '',
            ),
          );
        }
      }
    }

    return list;
  }

  static bool _looksLikeDirectAttachmentUrl(String? rawUrl) {
    if (rawUrl == null) return false;
    final value = rawUrl.trim();
    if (value.isEmpty) return false;

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    final path = uri.path.toLowerCase();
    if (path.isEmpty || path.endsWith('/')) return false;
    if (!path.contains('.')) return false;
    final ext = path.split('.').last;
    return const {
      'pdf',
      'mp3',
      'wav',
      'm4a',
      'aac',
      'ogg',
      'flac',
      'opus',
      'mp4',
      'mkv',
      'mov',
      'webm',
      'avi',
      'm3u8',
    }.contains(ext);
  }

  factory IslamhouseItem.fromJson(Map<String, dynamic> json) {
    final preparedBy = <IslamhouseContributor>[];
    final rawPreparedBy = json['prepared_by'];
    if (rawPreparedBy is List) {
      for (final person in rawPreparedBy) {
        if (person is Map<String, dynamic>) {
          preparedBy.add(IslamhouseContributor.fromJson(person));
        }
      }
    }

    final attachments = <IslamhouseAttachment>[];
    attachments.addAll(_parseAttachments(json['attachments']));
    attachments.addAll(_parseAttachments(json['file_urls']));
    final itemType = normalizeTypeKey((json['type'] ?? '').toString());
    final allowMediaFallback = _mediaItemTypes.contains(itemType);

    final displayBoxUrl = _parseHttpUrl(json['display_box_mp4_default']);
    if (attachments.isEmpty &&
        displayBoxUrl != null &&
        allowMediaFallback &&
        _looksLikeDirectAttachmentUrl(displayBoxUrl)) {
      attachments.add(
        IslamhouseAttachment(
          url: displayBoxUrl,
          description: (json['title'] ?? '').toString(),
          extensionType: 'mp4',
          size: '',
        ),
      );
    }
    final directUrl = _parseHttpUrl(json['url']);
    if (attachments.isEmpty && _looksLikeDirectAttachmentUrl(directUrl)) {
      final directAttachment = IslamhouseAttachment(
        url: directUrl!,
        description: (json['title'] ?? '').toString(),
        extensionType: '',
        size: '',
      );
      final allowByType =
          (_mediaItemTypes.contains(itemType) &&
              (directAttachment.isAudio || directAttachment.isVideo)) ||
          directAttachment.isPdf;
      if (allowByType && directAttachment.isSupportedInApp) {
        attachments.add(directAttachment);
      }
    }
    final deduplicatedAttachments = <IslamhouseAttachment>[];
    final seenUrls = <String>{};
    for (final attachment in attachments) {
      final normalizedUrl = attachment.normalizedUrlForDedup;
      if (normalizedUrl.isEmpty || seenUrls.contains(normalizedUrl)) continue;
      seenUrls.add(normalizedUrl);
      deduplicatedAttachments.add(attachment);
    }

    final supportedAttachments = deduplicatedAttachments
        .where((attachment) => attachment.isSupportedInApp)
        .toList(growable: false);

    return IslamhouseItem(
      id: _parseInt(json['id']),
      sourceId: _parseInt(json['source_id']),
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      addDate: _parseInt(json['add_date']),
      description: _parseNullableString(json['description']),
      fullDescription: _parseNullableString(json['full_description']),
      content:
          _parseRichText(json['content']) ??
          _parseRichText(json['text']) ??
          _parseRichText(json['body']),
      image: _parseNullableString(json['image']),
      sourceLanguage: _parseNullableString(json['source_language']),
      translatedLanguage: _parseNullableString(
        json['translated_language'] ?? json['translation_language'],
      ),
      contributors: preparedBy,
      attachments: supportedAttachments,
    );
  }

  static String normalizeForSearch(String input) {
    return input
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  static String _displayTypeFromNormalized(String normalizedType) =>
      switch (normalizedType) {
        'videos' => 'فيديو',
        'video' => 'فيديو',
        'books' => 'كتاب',
        'book' => 'كتاب',
        'articles' => 'مقال',
        'article' => 'مقال',
        'audios' => 'صوتي',
        'audio' => 'صوتي',
        'khotab' => 'خطب الجمعة',
        'khotba' => 'خطب الجمعة',
        'khotbah' => 'خطب الجمعة',
        'khutbah' => 'خطب الجمعة',
        'fatwa' => 'فتوى',
        'fatawa' => 'فتوى',
        'favorites' => 'مختارات',
        'favorite' => 'مختارات',
        'favourites' => 'مختارات',
        'selected' => 'مختارات',
        'مختارات' => 'مختارات',
        'quran' => 'قرآن',
        _ => 'محتوى',
      };

  late final String _normalizedTypeCached = normalizeTypeKey(type);

  String get normalizedType => _normalizedTypeCached;

  late final String _displayTypeCached = _displayTypeFromNormalized(
    _normalizedTypeCached,
  );

  String get displayType => _displayTypeCached;

  late final String _primaryDescriptionCached = stripHtml(
    description ?? fullDescription ?? content ?? '',
  );

  String get primaryDescription => _primaryDescriptionCached;

  late final String _searchIndexCached = normalizeForSearch(
    '$title $_primaryDescriptionCached',
  );

  String get searchIndex => _searchIndexCached;

  String get primaryUrl {
    if (attachments.isNotEmpty) {
      return attachments.first.url;
    }
    return '';
  }

  bool get hasImage => (image ?? '').trim().isNotEmpty;

  bool get hasAttachments => attachments.isNotEmpty;

  bool get isHiddenType => hiddenBrowseTypes.contains(normalizedType);

  static String stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
