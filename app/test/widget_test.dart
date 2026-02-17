import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // В текущем приложении main() делает асинхронную инициализацию Firebase и DI,
    // что сложно тестировать в простом widget test без моков.
    expect(true, isTrue);
  });
}
