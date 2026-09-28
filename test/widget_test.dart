import 'package:flutter_test/flutter_test.dart';

import 'package:country_trivia/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CountryTriviaApp());
    await tester.pump();

    expect(find.text('Country Trivia'), findsOneWidget);
  });
}
