class IslamhouseAttachment {
  final String url;
  final String description;
  final String extensionType;
  final String size;

  const IslamhouseAttachment({
    required this.url,
    required this.description,
    required this.extensionType,
    required this.size,
  });

  factory IslamhouseAttachment.fromJson(Map<String, dynamic> json) {
    return IslamhouseAttachment(
      url: (json['url'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      extensionType: (json['extension_type'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
    );
  }

  bool get hasUrl => url.trim().isNotEmpty;

  String get normalizedType {
    final ext = extensionType.trim().toLowerCase();
    if (ext.isNotEmpty) return ext;

    final uri = Uri.tryParse(url);
    final last = (uri?.pathSegments.isNotEmpty ?? false)
        ? uri!.pathSegments.last.toLowerCase()
        : '';
    if (!last.contains('.')) return '';
    return last.split('.').last;
  }

  String get fileTypeLabel {
    final ext = normalizedType.toUpperCase();
    if (ext.isNotEmpty) return ext;
    return 'FILE';
  }

  bool get isPdf => normalizedType == 'pdf';

  bool get isAudio => const {
    'mp3',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'flac',
    'opus',
  }.contains(normalizedType);

  bool get isVideo => const {
    'mp4',
    'mkv',
    'mov',
    'webm',
    'avi',
    'm3u8',
  }.contains(normalizedType);

  bool get isSupportedInApp => isPdf || isAudio || isVideo;

  String get normalizedUrlForDedup {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) return url.trim();
    return parsed.replace(query: '', fragment: '').toString();
  }
}
