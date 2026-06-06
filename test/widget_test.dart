import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_order/main_staging.dart';

void main() {
  test('MyApp can be instantiated', () {
    expect(const MyApp(), isA<MyApp>());
  });

  testWidgets('MyApp renders without crashing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
