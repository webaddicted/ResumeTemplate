import 'package:flutter/material.dart';

import '../../constant/card_categories.dart';
import '../../theme/app_theme.dart';
import '../../../model/card_data.dart';
import 'card_template_specs.dart';

/// Renders [data] using its template + category. Dispatches to the family
/// renderer (invitation / business card / event pass / profile).
///
/// Each family renderer is category-aware: it uses the category's [icon] as a
/// decorative motif and tunes flourishes, so every design feels purpose-built
/// (romantic weddings, playful birthdays, somber memorials, sleek cards …).
Widget buildCardTemplate(CardData data) {
  final spec = CardCatalogue.byId(data.templateId);
  final category = CardCategories.byId(data.categoryId);
  switch (category.family) {
    case CardFamily.invitation:
      return _InvitationCard(spec: spec, data: data, category: category);
    case CardFamily.eventPass:
      return _EventPassCard(spec: spec, data: data, category: category);
    case CardFamily.businessCard:
      return _BusinessCard(spec: spec, data: data, category: category);
    case CardFamily.profile:
      return _ProfileCard(spec: spec, data: data, category: category);
  }
}

// ---- shared helpers --------------------------------------------------------
TextStyle _t(
  Color color, {
  double size = 13,
  FontWeight weight = FontWeight.w400,
  double? spacing,
  FontStyle? style,
  double height = 1.4,
}) =>
    TextStyle(
      fontFamily: AppTheme.fontFamily,
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      fontStyle: style,
      height: height,
    );

Color _soft(CardTemplateSpec s) => Color.lerp(s.ink, s.background, 0.4)!;
Color _tint(CardTemplateSpec s, double amt) =>
    Color.lerp(s.background, s.accent, amt)!;
Color _deep(CardTemplateSpec s, [double amt = 0.3]) =>
    Color.lerp(s.accent, Colors.black, amt)!;

LinearGradient _bgGradient(CardTemplateSpec s) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [s.background, _tint(s, 0.06)],
    );

LinearGradient _accentGradient(CardTemplateSpec s) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [s.accent, _deep(s, 0.28)],
    );

Widget _photoCircle(CardData d, Color border, {double size = 76}) {
  if (d.photo == null) return const SizedBox.shrink();
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: border, width: 2.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      image: DecorationImage(image: MemoryImage(d.photo!), fit: BoxFit.cover),
    ),
  );
}

/// Motif badge — the category icon in a soft accent disc, used as the
/// decorative crown of invitation cards.
Widget _motifBadge(CardTemplateSpec s, IconData icon,
    {double size = 46, Color? onColor}) {
  final fg = onColor ?? s.accent;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: fg.withValues(alpha: 0.12),
      border: Border.all(color: fg.withValues(alpha: 0.5)),
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: size * 0.5, color: fg),
  );
}

/// Flourish line — thin rule that fades toward the centre ornament.
Widget _flourish(CardTemplateSpec s, {bool reversed = false}) {
  return SizedBox(
    width: 46,
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reversed ? Alignment.centerRight : Alignment.centerLeft,
          end: reversed ? Alignment.centerLeft : Alignment.centerRight,
          colors: [s.accent.withValues(alpha: 0.0), s.accent],
        ),
      ),
    ),
  );
}

/// Ornamental divider: flourish — motif — flourish.
Widget _ornDivider(CardTemplateSpec s, IconData icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _flourish(s),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Icon(icon, size: 12, color: s.accent),
      ),
      _flourish(s, reversed: true),
    ],
  );
}

// ---------------------------------------------------------------------------
// Invitation family — ceremonial card with motif, watermark & flourishes.
// ---------------------------------------------------------------------------
class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.spec,
    required this.data,
    required this.category,
  });

  final CardTemplateSpec spec;
  final CardData data;
  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    final names = [data.get('name1'), data.get('name2')]
        .where((s) => s.isNotEmpty)
        .toList();
    final couple = names.join('  &  ');
    final icon = category.icon;

    Widget line(String key, {bool emphasise = false}) {
      if (!data.has(key)) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(
          data.get(key),
          textAlign: TextAlign.center,
          style: _t(
            emphasise ? spec.accent : spec.ink,
            size: emphasise ? 13.5 : 12.5,
            weight: emphasise ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _motifBadge(spec, icon),
        const SizedBox(height: 12),
        if (data.has('headline'))
          Text(
            data.get('headline').toUpperCase(),
            textAlign: TextAlign.center,
            style: _t(spec.accent,
                size: 12.5, weight: FontWeight.w700, spacing: 3),
          ),
        const SizedBox(height: 14),
        if (data.usesPhoto && data.photo != null) ...[
          _photoCircle(data, spec.accent, size: 90),
          const SizedBox(height: 14),
        ],
        if (data.has('host')) ...[
          line('host'),
          const SizedBox(height: 8),
        ],
        if (couple.isNotEmpty) ...[
          // Monogram for couples.
          if (names.length == 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${names[0][0]} & ${names[1][0]}'.toUpperCase(),
                style: _t(spec.accent.withValues(alpha: 0.55),
                    size: 14, weight: FontWeight.w700, spacing: 2),
              ),
            ),
          Text(
            couple,
            textAlign: TextAlign.center,
            style: _t(spec.ink, size: 30, weight: FontWeight.w900, height: 1.12),
          ),
        ],
        if (data.has('subtitle')) ...[
          const SizedBox(height: 5),
          Text(
            data.get('subtitle'),
            textAlign: TextAlign.center,
            style: _t(_soft(spec), size: 13.5, style: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 14),
        _ornDivider(spec, icon),
        const SizedBox(height: 14),
        if (data.has('message')) ...[
          Text(
            data.get('message'),
            textAlign: TextAlign.center,
            style: _t(spec.ink, size: 12.5, height: 1.55),
          ),
          const SizedBox(height: 14),
        ],
        if (data.has('program')) ...[
          for (final item in data.get('program').split('\n'))
            if (item.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(item.trim(),
                    textAlign: TextAlign.center,
                    style: _t(spec.ink, size: 12.5, weight: FontWeight.w500)),
              ),
          const SizedBox(height: 10),
        ],
        // Date highlighted in a soft pill.
        if (data.has('date'))
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: spec.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: spec.accent.withValues(alpha: 0.35)),
            ),
            child: Text(
              data.get('date'),
              textAlign: TextAlign.center,
              style: _t(spec.accent, size: 13, weight: FontWeight.w700),
            ),
          ),
        line('time'),
        if (data.has('venue'))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              data.get('venue'),
              textAlign: TextAlign.center,
              style: _t(spec.ink, size: 13.5, weight: FontWeight.w800),
            ),
          ),
        line('address'),
        if (data.has('rsvp')) ...[
          const SizedBox(height: 14),
          _flourish(spec, reversed: true),
          const SizedBox(height: 8),
          Text(
            'RSVP  ·  ${data.get('rsvp')}',
            textAlign: TextAlign.center,
            style: _t(_soft(spec), size: 11.5, weight: FontWeight.w600),
          ),
        ],
      ],
    );

    return _decorate(content, icon);
  }

  /// Variant-specific frame + gradient background + faint motif watermark.
  Widget _decorate(Widget content, IconData icon) {
    final inner = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Icon(icon,
                  size: 230, color: spec.accent.withValues(alpha: 0.05)),
            ),
          ),
        ),
        content,
      ],
    );

    switch (spec.variant) {
      case 0: // Ornate — double border + corner ornaments
        return Container(
          decoration: BoxDecoration(gradient: _bgGradient(spec)),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: spec.accent, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: spec.accent.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
                  child: inner,
                ),
                Positioned(
                    top: 6,
                    left: 6,
                    child: _CornerHook(true, true, color: spec.accent)),
                Positioned(
                    top: 6,
                    right: 6,
                    child: _CornerHook(true, false, color: spec.accent)),
                Positioned(
                    bottom: 6,
                    left: 6,
                    child: _CornerHook(false, true, color: spec.accent)),
                Positioned(
                    bottom: 6,
                    right: 6,
                    child: _CornerHook(false, false, color: spec.accent)),
              ],
            ),
          ),
        );
      case 1: // Banner — accent header strip with motif
        return Container(
          decoration: BoxDecoration(gradient: _bgGradient(spec)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(gradient: _accentGradient(spec)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 30),
                child: inner,
              ),
              Container(
                height: 12,
                decoration: BoxDecoration(gradient: _accentGradient(spec)),
              ),
            ],
          ),
        );
      case 3: // Gradient — full soft gradient + framed
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_tint(spec, 0.10), spec.background],
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
            child: inner,
          ),
        );
      case 2: // Classic — hairline rounded border
        return Container(
          decoration: BoxDecoration(gradient: _bgGradient(spec)),
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: spec.accent.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
            child: inner,
          ),
        );
      default: // Minimal
        return Container(
          decoration: BoxDecoration(gradient: _bgGradient(spec)),
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 32),
          child: inner,
        );
    }
  }
}

/// L-shaped corner ornament for the ornate invitation frame.
class _CornerHook extends StatelessWidget {
  const _CornerHook(this.top, this.left, {this.color = const Color(0xFF000000)});
  final bool top;
  final bool left;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: color, width: 2.5);
    return IgnorePointer(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: !top ? side : BorderSide.none,
            left: left ? side : BorderSide.none,
            right: !left ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business / visiting card — content-sized, four refined layouts.
// ---------------------------------------------------------------------------
class _BusinessCard extends StatelessWidget {
  const _BusinessCard({
    required this.spec,
    required this.data,
    required this.category,
  });

  final CardTemplateSpec spec;
  final CardData data;
  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String key, {Color? color}) {
      if (!data.has(key)) return const SizedBox.shrink();
      final c = color ?? spec.ink;
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color ?? spec.accent),
            const SizedBox(width: 9),
            Expanded(child: Text(data.get(key), style: _t(c, size: 11.5))),
          ],
        ),
      );
    }

    Widget monogram(Color bg, Color fg) => Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: fg.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(data.initials,
              style: _t(fg, size: 18, weight: FontWeight.w900)),
        );

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.has('company'))
          Text(data.get('company').toUpperCase(),
              style: _t(spec.accent,
                  size: 12, weight: FontWeight.w800, spacing: 1.5)),
        const SizedBox(height: 10),
        Text(data.get('name1'),
            style: _t(spec.ink, size: 22, weight: FontWeight.w900)),
        if (data.has('designation'))
          Text(data.get('designation'),
              style: _t(_soft(spec), size: 12.5, weight: FontWeight.w600)),
      ],
    );

    final contact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(Icons.phone_rounded, 'phone'),
        row(Icons.email_rounded, 'email'),
        row(Icons.language_rounded, 'website'),
        row(Icons.location_on_rounded, 'address'),
      ],
    );

    final Widget card = switch (spec.variant) {
      0 || 2 => Container(
          decoration: BoxDecoration(
            color: spec.background,
            border: Border.all(color: spec.accent.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(spec.variant == 2 ? 10 : 0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: _accentGradient(spec),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [header, const SizedBox(height: 18), contact],
                  ),
                ),
              ],
            ),
          ),
        ),
      1 => Container(
          decoration: BoxDecoration(
            color: spec.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(gradient: _accentGradient(spec)),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    monogram(Colors.white.withValues(alpha: 0.18), Colors.white),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.get('name1'),
                              style: _t(Colors.white,
                                  size: 19, weight: FontWeight.w900)),
                          if (data.has('designation'))
                            Text(data.get('designation'),
                                style: _t(Colors.white.withValues(alpha: 0.9),
                                    size: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.has('company'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(data.get('company'),
                            style: _t(spec.accent,
                                size: 12, weight: FontWeight.w700)),
                      ),
                    contact,
                  ],
                ),
              ),
            ],
          ),
        ),
      3 => Container(
          decoration: BoxDecoration(
            gradient: _accentGradient(spec),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  monogram(Colors.white.withValues(alpha: 0.18), Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.get('name1'),
                            style: _t(Colors.white,
                                size: 21, weight: FontWeight.w900)),
                        if (data.has('designation'))
                          Text(data.get('designation'),
                              style: _t(Colors.white.withValues(alpha: 0.9),
                                  size: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (final (ic, k) in const [
                (Icons.phone_rounded, 'phone'),
                (Icons.email_rounded, 'email'),
                (Icons.language_rounded, 'website'),
                (Icons.location_on_rounded, 'address'),
              ])
                if (data.has(k))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Icon(ic, size: 13, color: Colors.white70),
                      const SizedBox(width: 9),
                      Expanded(
                          child: Text(data.get(k),
                              style: _t(Colors.white, size: 11.5))),
                    ]),
                  ),
            ],
          ),
        ),
      _ => Container(
          color: spec.background,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 28, height: 3, color: spec.accent),
              ]),
              const SizedBox(height: 14),
              header,
              const SizedBox(height: 18),
              contact,
            ],
          ),
        ),
    };

    return Container(
      decoration: BoxDecoration(gradient: _bgGradient(spec)),
      padding: const EdgeInsets.all(26),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: card,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Event pass — ticket-style card with motif, details grid & QR stub.
// ---------------------------------------------------------------------------
class _EventPassCard extends StatelessWidget {
  const _EventPassCard({
    required this.spec,
    required this.data,
    required this.category,
  });

  final CardTemplateSpec spec;
  final CardData data;
  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    Widget kv(String label, String key) {
      if (!data.has(key)) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: _t(Colors.white.withValues(alpha: 0.65),
                    size: 9, spacing: 1.2)),
            const SizedBox(height: 1),
            Text(data.get(key),
                style: _t(Colors.white, size: 13, weight: FontWeight.w700)),
          ],
        ),
      );
    }

    final main = Container(
      decoration: BoxDecoration(
        gradient: _accentGradient(spec),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon,
                  size: 16, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text(data.get('headline'),
                  style: _t(Colors.white.withValues(alpha: 0.85),
                      size: 10, spacing: 2)),
            ],
          ),
          const SizedBox(height: 6),
          Text(data.get('event'),
              style: _t(Colors.white, size: 20, weight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: kv('Attendee', 'name1')),
              Expanded(child: kv('Type', 'passType')),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: kv('Date', 'date')),
              Expanded(child: kv('Time', 'time')),
            ],
          ),
          kv('Venue', 'venue'),
          kv('Seat / Gate', 'seat'),
        ],
      ),
    );

    final stub = Container(
      width: 92,
      decoration: BoxDecoration(
        color: _deep(spec, 0.45),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.qr_code_2_rounded, size: 48, color: _deep(spec)),
          ),
          const SizedBox(height: 10),
          if (data.has('code'))
            Text(data.get('code'),
                textAlign: TextAlign.center,
                style: _t(Colors.white.withValues(alpha: 0.85),
                    size: 8.5, spacing: 0.5)),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(gradient: _bgGradient(spec)),
      padding: const EdgeInsets.all(22),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: spec.accent.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: main),
                _Perforation(color: spec.background),
                stub,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed vertical perforation between ticket and stub.
class _Perforation extends StatelessWidget {
  const _Perforation({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          16,
          (_) => Container(
            width: 4,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile family — modern cover banner, overlapping medallion, chips.
// ---------------------------------------------------------------------------
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.spec,
    required this.data,
    required this.category,
  });

  final CardTemplateSpec spec;
  final CardData data;
  final DocCategory category;

  static const _handled = {'headline', 'name1', 'subtitle', 'about', 'interests'};

  @override
  Widget build(BuildContext context) {
    // variant: 1 solid banner, 3 gradient banner, 0 ornate bordered,
    // 2 classic, 4 minimal.
    final bannered = spec.variant == 1 || spec.variant == 3;

    final medallion = data.photo != null
        ? _photoCircle(data, Colors.white, size: 92)
        : Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.background,
              border: Border.all(color: spec.accent, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(data.initials,
                style: _t(spec.accent, size: 32, weight: FontWeight.w900)),
          );

    final detailRows = <Widget>[];
    for (final f in category.fields) {
      if (_handled.contains(f.key) || !data.has(f.key)) continue;
      detailRows.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_fieldIcon(f.key), size: 14, color: spec.accent),
            const SizedBox(width: 9),
            SizedBox(
              width: 90,
              child: Text(f.label,
                  style: _t(_soft(spec), size: 11.5, weight: FontWeight.w700)),
            ),
            Expanded(
                child: Text(data.get(f.key), style: _t(spec.ink, size: 12.5))),
          ],
        ),
      ));
    }

    final chips = data.has('interests')
        ? Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tag in data
                  .get('interests')
                  .split(RegExp(r'[,\n]'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: spec.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(tag,
                      style: _t(spec.ink, size: 11, weight: FontWeight.w600)),
                ),
            ],
          )
        : const SizedBox.shrink();

    final nameBlock = Column(
      children: [
        Text(data.get('name1'),
            textAlign: TextAlign.center,
            style: _t(spec.ink, size: 23, weight: FontWeight.w900)),
        if (data.has('subtitle'))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(data.get('subtitle'),
                textAlign: TextAlign.center,
                style: _t(spec.accent, size: 13.5, weight: FontWeight.w600)),
          ),
      ],
    );

    final bodyChildren = <Widget>[
      if (data.has('about')) ...[
        Text(data.get('about'),
            textAlign: TextAlign.center, style: _t(spec.ink, size: 12.5)),
        const SizedBox(height: 16),
      ],
      if (detailRows.isNotEmpty) ...[
        ...detailRows,
        const SizedBox(height: 14),
      ],
      chips,
    ];

    // Banner layouts: cover strip with overlapping medallion.
    if (bannered) {
      return Container(
        color: spec.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: spec.variant == 3
                        ? _accentGradient(spec)
                        : LinearGradient(colors: [spec.accent, spec.accent]),
                  ),
                ),
                Positioned(
                  bottom: -46,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.transparent, shape: BoxShape.circle),
                    child: medallion,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 54),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
              child: Column(children: [nameBlock, const SizedBox(height: 14), ...bodyChildren]),
            ),
          ],
        ),
      );
    }

    // Bordered / classic / minimal centered layouts.
    final centered = Column(
      children: [
        const SizedBox(height: 26),
        medallion,
        const SizedBox(height: 14),
        nameBlock,
        const SizedBox(height: 12),
        _ornDivider(spec, category.icon),
        const SizedBox(height: 14),
        ...bodyChildren,
        const SizedBox(height: 26),
      ],
    );

    if (spec.variant == 0) {
      return Container(
        decoration: BoxDecoration(gradient: _bgGradient(spec)),
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: spec.accent.withValues(alpha: 0.55), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: centered,
        ),
      );
    }
    if (spec.variant == 2) {
      return Container(
        decoration: BoxDecoration(gradient: _bgGradient(spec)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: centered,
      );
    }
    return Container(
      color: spec.background,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: centered,
    );
  }

  IconData _fieldIcon(String key) => switch (key) {
        'phone' => Icons.phone_rounded,
        'email' => Icons.email_rounded,
        'website' => Icons.language_rounded,
        'location' => Icons.location_on_rounded,
        'school' => Icons.school_rounded,
        'roll' => Icons.tag_rounded,
        _ => Icons.chevron_right_rounded,
      };
}
