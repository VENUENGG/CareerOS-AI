import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart'
    show TokenStorage;
import 'providers/app_providers.dart'
    show AuthProvider, CareerDataProvider, AvatarController;
import 'repositories/careeros_repository.dart'
    show CareerOSRepository;

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final repository = CareerOSRepository(apiClient);

  runApp(
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
}