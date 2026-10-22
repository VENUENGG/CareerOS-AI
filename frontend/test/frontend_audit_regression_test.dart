import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:careeros/core/utils/currency_formatter.dart';
import 'package:careeros/core/utils/profile_completeness.dart';
import 'package:careeros/core/utils/url_helper.dart';
import 'package:careeros/core/validation/validators.dart';
import 'package:careeros/models/models.dart';
import 'package:careeros/providers/app_providers.dart';
import 'package:careeros/core/network/api_client.dart';
import 'package:careeros/core/network/api_config.dart';
import 'package:careeros/core/storage/token_storage.dart';
import 'package:careeros/repositories/careeros_repository.dart';

class _FakeTokenStorage extends TokenStorage {
  String? token;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async => token = value;
  @override
  Future<void> clear() async => token = null;
}

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats INR in Lakhs and Crores with clear units', () {
      expect(CurrencyFormatter.formatCompact(1500000, 'INR'), '₹15.0 LPA');
      expect(CurrencyFormatter.formatCompact(1200000, 'INR'), '₹12.0 LPA');
      expect(CurrencyFormatter.formatCompact(10000000, 'INR'), '₹1.0 Cr');
      expect(CurrencyFormatter.formatCompact(25000000, 'INR'), '₹2.5 Cr');
      expect(CurrencyFormatter.formatCompact(50000, 'INR'), '₹50K');
    });

    test('formats USD in K and M', () {
      expect(CurrencyFormatter.formatCompact(150000, 'USD'), '\$150K');
      expect(CurrencyFormatter.formatCompact(1200000, 'USD'), '\$1.2M');
      expect(CurrencyFormatter.formatCompact(800, 'USD'), '\$800');
    });

    test('handles negative, zero, null, and NaN safely', () {
      expect(CurrencyFormatter.formatCompact(null, 'INR'), '—');
      expect(CurrencyFormatter.formatCompact(0, 'INR'), '₹0');
      expect(CurrencyFormatter.formatCompact(-5000, 'INR'), '—');
      expect(CurrencyFormatter.formatCompact(double.nan, 'INR'), '—');
    });

    test('resolves currency intelligently from location or code', () {
      expect(CurrencyFormatter.resolveCurrency(currency: 'INR'), 'INR');
      expect(CurrencyFormatter.resolveCurrency(currency: 'USD'), 'USD');
      expect(CurrencyFormatter.resolveCurrency(currency: 'GBP'), 'GBP');
      expect(CurrencyFormatter.resolveCurrency(currency: 'EUR'), 'EUR');
      expect(CurrencyFormatter.resolveCurrency(location: 'Bengaluru, India'), 'INR');
      expect(CurrencyFormatter.resolveCurrency(location: 'Mumbai'), 'INR');
      expect(CurrencyFormatter.resolveCurrency(location: 'San Francisco, CA'), 'USD');
      expect(CurrencyFormatter.resolveCurrency(location: 'Delhi, India'), 'INR');
    });
  });

  group('ProfileCompletenessCalculator Tests', () {
    late CareerDataProvider provider;

    setUp(() {
      final tokenStorage = _FakeTokenStorage();
      final client = ApiClient(tokenStorage);
      final repo = CareerOSRepository(client);
      provider = CareerDataProvider(repo);
    });

    test('empty profile and empty data yields zero completeness', () {
      final score = ProfileCompletenessCalculator.calculate(null, provider);
      expect(score, 0);
    });

    test('whitespace and empty strings do not grant completeness points', () {
      final profile = UserProfile.fromJson({
        'firstName': '   ',
        'lastName': '',
        'headline': '  ',
        'currentJobTitle': '',
        'bio': '\n',
        'city': ' ',
      });
      final score = ProfileCompletenessCalculator.calculate(profile, provider);
      expect(score, 0);
    });

    test('complete profile with all career sections caps at 100%', () {
      final profile = UserProfile.fromJson({
        'firstName': 'Jane',
        'lastName': 'Doe',
        'headline': 'Senior Staff Engineer',
        'currentJobTitle': 'Staff Software Engineer',
        'bio': 'Passionate builder with 10+ years of experience.',
        'city': 'Bengaluru',
        'country': 'India',
        'linkedinUrl': 'https://linkedin.com/in/janedoe',
        'githubUrl': 'https://github.com/janedoe',
      });

      provider.debugSeed(
        experience: [
          Experience.fromJson({'id': 1, 'companyName': 'Tech Corp', 'jobTitle': 'Senior Dev'}),
        ],
        education: [
          Education.fromJson({'id': 1, 'institutionName': 'IIT', 'degree': 'B.Tech'}),
        ],
        skills: List.generate(6, (i) => Skill.fromJson({'id': i + 1, 'skillName': 'Skill $i'})),
        projects: [
          Project.fromJson({'id': 1, 'projectName': 'CareerOS AI'}),
        ],
        certifications: [
          Certification.fromJson({'id': 1, 'name': 'GCP Architect'}),
        ],
        languages: [
          Language.fromJson({'id': 1, 'languageName': 'English'}),
        ],
      );

      final score = ProfileCompletenessCalculator.calculate(profile, provider);
      expect(score, 100);
    });

    test('suggests accurate missing items for incomplete profiles', () {
      final profile = UserProfile.fromJson({
        'firstName': 'John',
      });
      final missing = ProfileCompletenessCalculator.getMissingItems(profile, provider);
      final labels = missing.map((m) => m.label).toList();

      expect(labels, contains('Add a professional headline'));
      expect(labels, contains('Add your current role'));
      expect(labels, contains('Add your core skills'));
      expect(labels, contains('Add work experience'));
      expect(labels, contains('Add education'));
    });
  });

  group('Validators URL and Schemaless Normalization Tests', () {
    test('accepts schemaless URLs common in user profiles', () {
      expect(Validators.url('linkedin.com/in/johndoe'), isNull);
      expect(Validators.url('github.com/johndoe'), isNull);
      expect(Validators.url('www.myportfolio.com'), isNull);
      expect(Validators.url('myportfolio.dev/projects'), isNull);
    });

    test('accepts standard https and http URLs', () {
      expect(Validators.url('https://linkedin.com/in/johndoe'), isNull);
      expect(Validators.url('http://example.com'), isNull);
    });

    test('rejects truly invalid or malformed strings', () {
      expect(Validators.url('not-a-url'), isNotNull);
      expect(Validators.url('http://'), isNotNull);
      expect(Validators.url('https://'), isNotNull);
      expect(Validators.url('random text with spaces'), isNotNull);
    });

    test('null or empty value passes if not marked required', () {
      expect(Validators.url(null), isNull);
      expect(Validators.url(''), isNull);
      expect(Validators.url('   '), isNull);
    });
  });

  group('UrlHelper Launch Tests', () {
    test('isUrl correctly identifies valid web addresses', () {
      expect(UrlHelper.isUrl('https://careeros.ai'), isTrue);
      expect(UrlHelper.isUrl('http://github.com/user'), isTrue);
      expect(UrlHelper.isUrl('linkedin.com/in/user'), isTrue);
      expect(UrlHelper.isUrl(''), isFalse);
      expect(UrlHelper.isUrl(null), isFalse);
      expect(UrlHelper.isUrl('not an address'), isFalse);
    });
  });

  group('Backend Date Serialization Tests', () {
    test('DateFormat produces yyyy-MM-dd for backend LocalDate compatibility', () {
      final dt = DateTime(2026, 10, 19, 14, 30, 45);
      final formatted = DateFormat('yyyy-MM-dd').format(dt);
      expect(formatted, '2026-10-19');
      // Ensure no time components or ISO T separators are present
      expect(formatted.contains('T'), isFalse);
      expect(formatted.contains(':'), isFalse);
    });
  });

  group('ATS Form Field Validation Tests', () {
    test('requires Job Description when analysis is job specific', () {
      expect(Validators.required('', fieldName: 'Job Description'), isNotNull);
      expect(Validators.required(null, fieldName: 'Job Description'), isNotNull);
      expect(Validators.minLength('too short', 20, fieldName: 'Job Description'), isNotNull);
      expect(
        Validators.required(
          'We are looking for a Senior Software Engineer with Flutter and Java experience.',
          fieldName: 'Job Description',
        ),
        isNull,
      );
    });
  });

  group('Salary Form Field Validation Tests', () {
    test('requires Industry as mandated by backend SalaryEstimateRequest', () {
      expect(Validators.required('', fieldName: 'Industry'), isNotNull);
      expect(Validators.required(null, fieldName: 'Industry'), isNotNull);
      expect(Validators.required('Technology', fieldName: 'Industry'), isNull);
    });
  });

  group('CurrencyFormatter Unknown & International Currency Tests', () {
    test('does not falsely label unknown or null currency as USD', () {
      expect(CurrencyFormatter.formatCompact(150000, null), '150K');
      expect(CurrencyFormatter.formatCompact(150000, ''), '150K');
      expect(CurrencyFormatter.format(150000, null), '150K / yr');
      expect(CurrencyFormatter.format(150000, ''), '150K / yr');
      expect(CurrencyFormatter.symbol(null), '');
      expect(CurrencyFormatter.symbol(''), '');
    });

    test('formats multi-character currencies cleanly with suffix code', () {
      expect(CurrencyFormatter.formatCompact(150000, 'CAD'), '150K CAD');
      expect(CurrencyFormatter.formatCompact(1200000, 'AUD'), '1.2M AUD');
    });

    test('resolves international and unknown currencies without false USD defaults', () {
      expect(CurrencyFormatter.resolveCurrency(location: 'London, UK'), 'GBP');
      expect(CurrencyFormatter.resolveCurrency(location: 'Berlin, Germany'), 'EUR');
      expect(CurrencyFormatter.resolveCurrency(location: 'Toronto, Canada'), 'CAD');
      expect(CurrencyFormatter.resolveCurrency(location: 'Tokyo, Japan'), 'JPY');
      expect(CurrencyFormatter.resolveCurrency(location: 'Sydney, Australia'), 'AUD');
      expect(CurrencyFormatter.resolveCurrency(location: 'Random Unknown City'), isNull);
      expect(CurrencyFormatter.resolveCurrency(location: ''), isNull);
    });
  });

  group('PDF Validation and Error Handling Tests', () {
    test('accepts valid PDF magic bytes (%PDF-)', () async {
      final fakeApi = _FakePdfApiClient(bytes: [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34]);
      final repo = CareerOSRepository(fakeApi);
      final bytes = await repo.resumePdfBytes(1);
      expect(bytes.length, 8);
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
      expect(bytes[4], 0x2D); // -
    });

    test('throws ApiException on empty PDF response from server', () async {
      final fakeApi = _FakePdfApiClient(bytes: []);
      final repo = CareerOSRepository(fakeApi);
      expect(
        () => repo.resumePdfBytes(1),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('empty PDF'))),
      );
    });

    test('throws ApiException on non-PDF bytes (e.g. server error payload)', () async {
      final errorPayload = '{"status":500,"message":"Failed to generate PDF"}'.codeUnits;
      final fakeApi = _FakePdfApiClient(bytes: errorPayload);
      final repo = CareerOSRepository(fakeApi);
      expect(
        () => repo.resumePdfBytes(1),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('Failed to generate PDF'))),
      );
    });
  });

  group('Social Links 404 & Conflict Retry Tests', () {
    test('socialLinks returns null on 404 not found', () async {
      final fakeApi = _FakeSocialApiClient(getThrows404: true);
      final repo = CareerOSRepository(fakeApi);
      final result = await repo.socialLinks();
      expect(result, isNull);
    });

    test('saveSocialLinks falls back to PUT if POST returns 409 already exists', () async {
      final fakeApi = _FakeSocialApiClient(postThrows409: true);
      final repo = CareerOSRepository(fakeApi);
      await repo.saveSocialLinks({'linkedinUrl': 'https://linkedin.com/in/test'}, isUpdate: false);
      expect(fakeApi.putCalled, isTrue);
    });

    test('saveSocialLinks falls back to POST if PUT returns 404 not found', () async {
      final fakeApi = _FakeSocialApiClient(putThrows404: true);
      final repo = CareerOSRepository(fakeApi);
      await repo.saveSocialLinks({'linkedinUrl': 'https://linkedin.com/in/test'}, isUpdate: true);
      expect(fakeApi.postCalled, isTrue);
    });
  });

  group('ApiConfig Tests', () {
    test('resolves non-empty baseUrl and handles platform configuration', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl.contains('8080') || ApiConfig.baseUrl == '/api', isTrue);
    });
  });
}

class _FakePdfApiClient extends ApiClient {
  final List<int> bytes;
  _FakePdfApiClient({required this.bytes}) : super(_FakeTokenStorage());

  @override
  Future<List<int>> getBytes(String path) async => bytes;
}

class _FakeSocialApiClient extends ApiClient {
  final bool getThrows404;
  final bool postThrows409;
  final bool putThrows404;
  bool postCalled = false;
  bool putCalled = false;

  _FakeSocialApiClient({
    this.getThrows404 = false,
    this.postThrows409 = false,
    this.putThrows404 = false,
  }) : super(_FakeTokenStorage());

  @override
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    if (getThrows404) {
      throw ApiException('Social links not found', statusCode: 404);
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: null,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    postCalled = true;
    if (postThrows409) {
      throw ApiException('Social links already exist', statusCode: 409);
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: null,
      statusCode: 201,
    );
  }

  @override
  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    putCalled = true;
    if (putThrows404) {
      throw ApiException('Social links not found', statusCode: 404);
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: null,
      statusCode: 200,
    );
  }
}
