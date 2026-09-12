// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read the values of widget properties, and verify that they are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:careeros/app/app.dart';
import 'package:careeros/providers/app_providers.dart';
import 'package:careeros/core/network/api_client.dart';
import 'package:careeros/core/storage/token_storage.dart';
import 'package:careeros/repositories/careeros_repository.dart';

void main() {
  testWidgets('CareerOSApp builds successfully', (WidgetTester tester) async {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage);
    final repository = CareerOSRepository(apiClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TokenStorage>.value(value: tokenStorage),
          Provider<ApiClient>.value(value: apiClient),
          Provider<CareerOSRepository>.value(value: repository),
          ChangeNotifierProvider(create: AuthProvider.create),
          ChangeNotifierProvider(create: CareerDataProvider.create),
          ChangeNotifierProvider(create: (_) => AvatarController()),
        ],
        child: const CareerOSApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}