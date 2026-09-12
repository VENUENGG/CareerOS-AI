import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/avatar_storage.dart';
import '../core/storage/token_storage.dart';
import '../core/widgets/avatar.dart';
import '../models/models.dart';
import '../repositories/careeros_repository.dart';

class AuthProvider extends ChangeNotifier {
  final CareerOSRepository _repository;
  final TokenStorage _tokenStorage;

  AuthProvider(this._repository, this._tokenStorage) {
    _restore();
  }

  static AuthProvider create(BuildContext context) {
    return AuthProvider(
      context.read<CareerOSRepository>(),
      context.read<TokenStorage>(),
    );
  }

  bool _loading = true;
  bool _authenticated = false;
  String? _error;
  UserProfile? _profileData;

  bool get loading => _loading;
  bool get authenticated => _authenticated;
  String? get error => _error;
  UserProfile? get profileData => _profileData;

  Future<void> _restore() async {
    _authenticated = await _tokenStorage.read() != null;
    if (_authenticated) {
      try {
        _profileData = await _repository.profile();
      } on ApiException catch (e) {
        // Only an invalid/expired session should log the user out. A user
        // who hasn't completed onboarding yet has no profile (404) and a
        // transient server error is not proof the token is bad — in both
        // cases we keep the session and simply have no profile data yet.
        if (e.statusCode == 401 || e.statusCode == 403) {
          await _tokenStorage.clear();
          _authenticated = false;
        }
      } catch (_) {
        // Network/parse error unrelated to auth — keep the session alive.
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.login(email, password);
      await _tokenStorage.write(result.accessToken);
      _authenticated = true;
      // A brand-new user has valid credentials but no profile yet (created
      // later via onboarding) — that must not fail the login itself.
      try {
        _profileData = await _repository.profile();
      } catch (_) {
        _profileData = null;
      }
      return true;
    } catch (e) {
      _authenticated = false;
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String firstName, String lastName, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(firstName, lastName, email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setProfile(UserProfile profile) {
    _profileData = profile;
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _authenticated = false;
    _profileData = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }
}

class CareerDataProvider extends ChangeNotifier {
  final CareerOSRepository _repository;

  CareerDataProvider(this._repository);

  static CareerDataProvider create(BuildContext context) {
    return CareerDataProvider(context.read<CareerOSRepository>());
  }

  bool _loading = false;
  String? _error;
  List<Education> _education = [];
  List<Experience> _experience = [];
  List<Skill> _skills = [];
  List<Project> _projects = [];
  List<Certification> _certifications = [];
  List<Language> _languages = [];
  List<Resume> _resumes = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Education> get education => _education;
  List<Experience> get experience => _experience;
  List<Skill> get skills => _skills;
  List<Project> get projects => _projects;
  List<Certification> get certifications => _certifications;
  List<Language> get languages => _languages;
  List<Resume> get resumes => _resumes;

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.educations(),
        _repository.experiences(),
        _repository.skills(),
        _repository.projects(),
        _repository.certifications(),
        _repository.languages(),
        _repository.resumes(),
      ]);
      _education = results[0] as List<Education>;
      _experience = results[1] as List<Experience>;
      _skills = results[2] as List<Skill>;
      _projects = results[3] as List<Project>;
      _certifications = results[4] as List<Certification>;
      _languages = results[5] as List<Language>;
      _resumes = results[6] as List<Resume>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshResumes() async {
    try {
      _resumes = await _repository.resumes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class AvatarController extends ChangeNotifier {
  final AvatarControllerImpl _impl = AvatarControllerImpl();

  AvatarStyle get selectedStyle => _impl.selectedStyle;
  String? get initials => _impl.initials;

  Future<void> initialize(UserProfile? profile) => _impl.initialize(profile);
  Future<void> selectAvatar(AvatarStyle style, UserProfile? profile) => _impl.selectAvatar(style, profile);
}

class AvatarControllerImpl {
  AvatarStyle _selectedStyle = AvatarStyle.initials;
  String? _cachedInitials;

  AvatarStyle get selectedStyle => _selectedStyle;
  String? get initials => _cachedInitials;

  Future<void> initialize(UserProfile? profile) async {
    try {
      _selectedStyle = await AvatarStorage.getSelectedAvatar();
    } catch (_) {
      // Local avatar preference unavailable (platform channel not ready,
      // storage denied, etc.) -- fall back to the initials avatar rather
      // than leaving the profile page's build in an unhandled-error state.
    }
    if (profile != null) {
      _cachedInitials = await AvatarStorage.getInitials(profile);
    }
  }

  Future<void> selectAvatar(AvatarStyle style, UserProfile? profile) async {
    _selectedStyle = style;
    try {
      await AvatarStorage.setSelectedAvatar(style);
    } catch (_) {
      // The selection still applies for this session even if it can't be
      // persisted; the user just won't see it after a restart.
    }
    if (profile != null) {
      _cachedInitials = await AvatarStorage.getInitials(profile);
    }
  }
}