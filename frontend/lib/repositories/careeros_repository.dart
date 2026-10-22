import '../core/network/api_client.dart';
import '../models/models.dart';

class CareerOSRepository {
  final ApiClient api;
  CareerOSRepository(this.api);

  Future<AuthResult> login(String email,String password) async { final r=await api.post('/v1/users/login',data:{'email':email,'password':password}); final d=r.data['data']; return AuthResult.fromJson(Map<String,dynamic>.from(d)); }
  Future<String> register(String first,String last,String email,String password) async { final r=await api.post('/v1/users/register',data:{'firstName':first,'lastName':last,'email':email,'password':password}); return (r.data['message']??'Registration successful').toString(); }
  Future<UserProfile> profile() async { final r=await api.get('/v1/profile/me'); return UserProfile.fromJson(Map<String,dynamic>.from(r.data['data'])); }
  Future<UserProfile> createProfile(Map<String,dynamic> data) async { final r=await api.post('/v1/profile',data:data); return UserProfile.fromJson(Map<String,dynamic>.from(r.data['data'])); }
  Future<UserProfile> updateProfile(Map<String,dynamic> data) async { final r=await api.put('/v1/profile/me',data:data); return UserProfile.fromJson(Map<String,dynamic>.from(r.data['data'])); }

  Future<List<Education>> educations() async => _list('/v1/education',Education.fromJson);
  Future<List<Experience>> experiences() async => _list('/v1/experience',Experience.fromJson);
  Future<List<Skill>> skills() async => _list('/v1/skills',Skill.fromJson);
  Future<List<Project>> projects() async => _list('/v1/projects',Project.fromJson);
  Future<List<Certification>> certifications() async => _list('/v1/certifications',Certification.fromJson);
  Future<List<Language>> languages() async => _list('/v1/languages',Language.fromJson);
  Future<SocialLinks?> socialLinks() async {
    try {
      final r = await api.get('/v1/social-links');
      return SocialLinks.fromJson(Map<String, dynamic>.from(r.data));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
  Future<List<Resume>> resumes() async => _list('/v1/resumes',Resume.fromJson);

  Future<List<T>> _list<T>(String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final r = await api.get(path);
      final raw = r.data;
      final list = raw is List ? raw : (raw['data'] ?? []);
      return List<T>.from(list.map((e) => parse(Map<String, dynamic>.from(e))));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return <T>[];
      rethrow;
    }
  }
  Future<void> createEducation(Map<String,dynamic>d)=>api.post('/v1/education',data:d);
  Future<void> createExperience(Map<String,dynamic>d)=>api.post('/v1/experience',data:d);
  Future<void> createSkill(Map<String,dynamic>d)=>api.post('/v1/skills',data:d);
  Future<void> createProject(Map<String,dynamic>d)=>api.post('/v1/projects',data:d);
  Future<void> createCertification(Map<String,dynamic>d)=>api.post('/v1/certifications',data:d);
  Future<void> createLanguage(Map<String,dynamic>d)=>api.post('/v1/languages',data:d);
  Future<void> updateEducation(int id,Map<String,dynamic>d)=>api.put('/v1/education/$id',data:d);
  Future<void> updateExperience(int id,Map<String,dynamic>d)=>api.put('/v1/experience/$id',data:d);
  Future<void> updateSkill(int id,Map<String,dynamic>d)=>api.put('/v1/skills/$id',data:d);
  Future<void> updateProject(int id,Map<String,dynamic>d)=>api.put('/v1/projects/$id',data:d);
  Future<void> updateCertification(int id,Map<String,dynamic>d)=>api.put('/v1/certifications/$id',data:d);
  Future<void> updateLanguage(int id,Map<String,dynamic>d)=>api.put('/v1/languages/$id',data:d);
  Future<void> deleteEducation(int id)=>api.delete('/v1/education/$id');
  Future<void> deleteExperience(int id)=>api.delete('/v1/experience/$id');
  Future<void> deleteSkill(int id)=>api.delete('/v1/skills/$id');
  Future<void> deleteProject(int id)=>api.delete('/v1/projects/$id');
  Future<void> deleteCertification(int id)=>api.delete('/v1/certifications/$id');
  Future<void> deleteLanguage(int id)=>api.delete('/v1/languages/$id');
  Future<void> saveSocialLinks(Map<String,dynamic>d, {bool isUpdate = false}) async {
    if (isUpdate) {
      try {
        await api.put('/v1/social-links', data: d);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          await api.post('/v1/social-links', data: d);
        } else {
          rethrow;
        }
      }
    } else {
      try {
        await api.post('/v1/social-links', data: d);
      } on ApiException catch (e) {
        if (e.statusCode == 409 || e.statusCode == 400) {
          await api.put('/v1/social-links', data: d);
        } else {
          rethrow;
        }
      }
    }
  }
  Future<void> updateSocialLinks(Map<String,dynamic>d) => api.put('/v1/social-links', data: d);
  Future<void> deleteSocialLinks() => api.delete('/v1/social-links');
  Future<Resume> createResume(Map<String,dynamic>d) async { final r=await api.post('/v1/resumes',data:d); return Resume.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<Resume> updateResume(int id, Map<String,dynamic>d) async { final r=await api.put('/v1/resumes/$id',data:d); return Resume.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<void> deleteById(String path,int id)=>api.delete('$path/$id');

  Future<String> aiGenerate(String prompt) async { final r=await api.post('/v1/ai/generate',data:{'prompt':prompt}); return r.data.toString(); }
  Future<CareerCoach> careerCoach(String goal) async { final r=await api.post('/v1/ai/career-coach',data:{'goal':goal}); return CareerCoach.fromJson(Map<String,dynamic>.from(r.data)); }
  // ATS analysis requires the resume to already have a "selection" of which
  // profile items (skills/experience/etc.) it includes; the backend 404s
  // otherwise. Ensure one exists (defaulting to "everything the user has")
  // before running an analysis so a resume that was never curated still works.
  Future<bool> hasResumeSelections(int resumeId) async {
    try {
      await api.get('/v1/resumes/$resumeId/selections');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }
  Future<void> saveResumeSelections(int resumeId, Map<String,dynamic> d) => api.post('/v1/resumes/$resumeId/selections', data: d);
  // Shared by every feature that needs a resume "rendered" -- ATS analysis,
  // PDF export, and the HTML preview all 400 with "Resume selections not
  // found" otherwise. One helper instead of duplicating this check at each
  // call site.
  Future<void> ensureResumeSelections(int resumeId, {
    required List<int> skillIds,
    required List<int> projectIds,
    required List<int> experienceIds,
    required List<int> educationIds,
    required List<int> certificationIds,
    required List<int> languageIds,
    bool force = false,
  }) async {
    if (!force) {
      try {
        final r = await api.get('/v1/resumes/$resumeId/selections');
        final data = r.data is Map ? Map<String, dynamic>.from(r.data) : null;
        if (data != null) {
          final hasSavedContent = (data['skillIds'] as List? ?? []).isNotEmpty ||
              (data['projectIds'] as List? ?? []).isNotEmpty ||
              (data['experienceIds'] as List? ?? []).isNotEmpty ||
              (data['educationIds'] as List? ?? []).isNotEmpty ||
              (data['certificationIds'] as List? ?? []).isNotEmpty ||
              (data['languageIds'] as List? ?? []).isNotEmpty;
          final userHasContent = skillIds.isNotEmpty ||
              projectIds.isNotEmpty ||
              experienceIds.isNotEmpty ||
              educationIds.isNotEmpty ||
              certificationIds.isNotEmpty ||
              languageIds.isNotEmpty;
          if (hasSavedContent || !userHasContent) {
            return;
          }
        }
      } on ApiException catch (e) {
        if (e.statusCode != 404) rethrow;
      }
    }
    await saveResumeSelections(resumeId, {
      'skillIds': skillIds,
      'projectIds': projectIds,
      'experienceIds': experienceIds,
      'educationIds': educationIds,
      'certificationIds': certificationIds,
      'languageIds': languageIds,
    });
  }

  Future<List<int>> resumePdfBytes(int resumeId) async {
    final bytes = await api.getBytes('/v1/resumes/$resumeId/pdf');
    if (bytes.isEmpty) {
      throw ApiException('Received empty PDF content from server');
    }
    // PDF files start with the magic header %PDF- (0x25, 0x50, 0x44, 0x46, 0x2D)
    if (bytes.length < 5 ||
        bytes[0] != 0x25 ||
        bytes[1] != 0x50 ||
        bytes[2] != 0x44 ||
        bytes[3] != 0x46) {
      final sample = String.fromCharCodes(bytes.take(200));
      if (sample.contains('error') || sample.contains('message') || sample.startsWith('{')) {
        throw ApiException('Failed to generate PDF: $sample');
      }
      throw ApiException('Invalid PDF format received from server');
    }
    return bytes;
  }

  Future<AtsAnalysis> atsAnalyze(int resumeId, String type, {String? jobTitle, String? jobDescription}) async {
    final payload = <String, dynamic>{'analysisType': type};
    if (type == 'JOB_SPECIFIC') {
      if (jobTitle != null && jobTitle.isNotEmpty) payload['jobTitle'] = jobTitle;
      if (jobDescription != null && jobDescription.isNotEmpty) payload['jobDescription'] = jobDescription;
    }
    final r = await api.post('/v1/resumes/$resumeId/ats/analyze', data: payload);
    return AtsAnalysis.fromJson(Map<String, dynamic>.from(r.data));
  }

  Future<AtsAnalysis?> atsLatest(int resumeId) async {
    try {
      final r = await api.get('/v1/resumes/$resumeId/ats/latest');
      return AtsAnalysis.fromJson(Map<String, dynamic>.from(r.data));
    } on ApiException catch (e) {
      if (e.statusCode == 404 || (e.statusCode == 400 && e.message.contains('No ATS analysis found'))) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<AtsAnalysis>> atsHistory(int resumeId) async {
    try {
      final r = await api.get('/v1/resumes/$resumeId/ats/history');
      final data = r.data;
      final list = data is List ? data : (data is Map && data['data'] is List ? data['data'] as List : []);
      return List<AtsAnalysis>.from(list.map((e) => AtsAnalysis.fromJson(Map<String, dynamic>.from(e))));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }
  Future<SalaryEstimate> salaryEstimate(Map<String,dynamic>d) async { final r=await api.post('/v1/salary/estimate',data:d); return SalaryEstimate.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<SalaryCompare> salaryCompare(Map<String,dynamic>d) async { final r=await api.post('/v1/salary/compare',data:d); return SalaryCompare.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<List<SalaryEstimate>> salaryHistory() async { final r=await api.get('/v1/salary/history'); return List<SalaryEstimate>.from((r.data as List).map((e)=>SalaryEstimate.fromJson(Map<String,dynamic>.from(e)))); }
}
