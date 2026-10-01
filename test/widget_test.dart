import 'package:flutter_test/flutter_test.dart';
import 'package:fitvisor_app/main.dart';

void main() {
  testWidgets('FitVisor app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitVisorApp());
    expect(find.text('FitVisor'), findsOneWidget);
  });
}
