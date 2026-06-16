import 'package:flutter_test/flutter_test.dart';
import 'package:quico/app/quico_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Quico app launches without error', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Quico Test')),
          ),
        ),
      ),
    );
    expect(find.text('Quico Test'), findsOneWidget);
  });
}
