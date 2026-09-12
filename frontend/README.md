# CareerOS Flutter

Flutter client for the existing CareerOS Spring Boot backend.

## Backend
The client targets `http://10.0.2.2:8080` by default on the Android emulator. For a physical Android device use your PC LAN IP, e.g. `http://192.168.1.10:8080`. For iOS simulator use `http://127.0.0.1:8080`.

Change `ApiConfig.baseUrl` in `lib/core/network/api_config.dart` when needed.

## Run
```bash
flutter pub get
flutter run
```

The backend must already be running on port 8080.

## Architecture
UI -> Provider -> Repository -> Dio API client -> Spring Boot REST API

JWT access tokens are stored with `flutter_secure_storage` and automatically attached as `Authorization: Bearer <token>`.
