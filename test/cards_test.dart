import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/global/constant/card_categories.dart';
import 'package:template/global/utils/card_pdf_generator.dart';
import 'package:template/global/widgets/templates/card_renderers.dart';
import 'package:template/global/widgets/templates/card_template_specs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Widget child, double width) => MaterialApp(
        home: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      );

  test('17 categories registered, spanning all families', () {
    expect(CardCategories.all.length, 17);
    final families = CardCategories.all.map((c) => c.family).toSet();
    expect(families, hasLength(4)); // invitation, eventPass, business, profile
  });

  test('each category has exactly 50 designs with unique ids', () {
    final allIds = <String>{};
    for (final c in CardCategories.all) {
      final specs = CardCatalogue.forCategory(c.id);
      expect(specs.length, 50, reason: c.id);
      for (final s in specs) {
        expect(allIds.add(s.id), isTrue, reason: 'duplicate ${s.id}');
      }
    }
    // 17 categories × 50 = 850 total designs.
    expect(allIds.length, 850);
  });

  for (final c in CardCategories.all) {
    testWidgets('${c.id} renders sample at phone + wide', (tester) async {
      final id = CardCatalogue.defaultTemplateId(c.id);
      final data = c.sampleData(id);

      tester.view.physicalSize = const Size(360 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(buildCardTemplate(data), 360));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1280 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      await tester.pumpWidget(host(buildCardTemplate(data), 680));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('switching design variant re-renders without error',
      (tester) async {
    final cat = CardCategories.byId('inv_marriage');
    final specs = CardCatalogue.forCategory(cat.id);
    for (final s in [specs[0], specs[12], specs[27], specs[49]]) {
      final data = cat.sampleData(s.id);
      await tester.pumpWidget(host(buildCardTemplate(data), 680));
      expect(tester.takeException(), isNull);
    }
  });

  test('PDF generates non-empty bytes for one category per family', () async {
    for (final id in [
      'inv_marriage',
      'event_pass',
      'business_card',
      'personal_profile',
    ]) {
      final cat = CardCategories.byId(id);
      final data = cat.sampleData(CardCatalogue.defaultTemplateId(id));
      final bytes = await CardPdfGenerator.generate(data);
      expect(bytes.length, greaterThan(1000), reason: id);
    }
  });

  test('card PDF filename derives from content', () {
    final cat = CardCategories.byId('business_card');
    final data = cat.sampleData(CardCatalogue.defaultTemplateId('business_card'));
    expect(CardPdfGenerator.fileName(data), 'Deepak_Sharma_business_card.pdf');
  });

  test('empty card hides everything but renders safely', () {
    final cat = CardCategories.byId('inv_birthday');
    final data = cat.newData(CardCatalogue.defaultTemplateId('inv_birthday'));
    // No exception constructing; values only hold the headline.
    expect(data.get('name1'), '');
    expect(data.has('headline'), isTrue);
  });
}
