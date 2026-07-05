import 'dart:typed_data';

/// Rendering family a document category belongs to. Each family has one
/// shared renderer that all its categories reuse.
enum CardFamily { invitation, eventPass, businessCard, profile }

/// One editable field in a card form. Pure data — no Flutter types — so the
/// model stays UI-agnostic.
class CardFieldSpec {
  const CardFieldSpec(
    this.key,
    this.label, {
    this.hint = '',
    this.multiline = false,
  });

  final String key;
  final String label;
  final String hint;
  final bool multiline;
}

/// Generic content for any non-resume/biodata document (invitations, event
/// passes, business cards, profiles). Fields are stored loosely by key so a
/// single form and renderer family can serve many categories.
class CardData {
  CardData({
    required this.categoryId,
    required this.templateId,
    Map<String, String>? values,
    this.photo,
    this.usesPhoto = false,
  }) : values = values ?? {};

  final String categoryId;
  String templateId;
  final Map<String, String> values;

  /// Optional photo (raw bytes) — profiles/invitations may show one.
  Uint8List? photo;
  final bool usesPhoto;

  String get(String key) => values[key]?.trim() ?? '';
  bool has(String key) => get(key).isNotEmpty;
  void set(String key, String value) => values[key] = value;

  CardData copyWithTemplate(String id) => CardData(
        categoryId: categoryId,
        templateId: id,
        values: Map.of(values),
        photo: photo,
        usesPhoto: usesPhoto,
      )..templateId = id;

  String get initials {
    final name = get('name1').isNotEmpty
        ? get('name1')
        : get('headline');
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
