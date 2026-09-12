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
  Future<SocialLinks?> socialLinks() async { final r=await api.get('/v1/social-links'); return SocialLinks.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<List<Resume>> resumes() async => _list('/v1/resumes',Resume.fromJson);

  Future<List<T>> _list<T>(String path,T Function(Map<String,dynamic>) parse) async { final r=await api.get(path); final raw=r.data; final list=raw is List?raw:(raw['data']??[]); return List<T>.from(list.map((e)=>parse(Map<String,dynamic>.from(e)))); }
  Future<void> createEducation(Map<String,dynamic>d)=>api.post('/v1/education',data:d);
  Future<void> createExperience(Map<String,dynamic>d)=>api.post('/v1/experience',data:d);
  Future<void> createSkill(Map<String,dynamic>d)=>api.post('/v1/skills',data:d);
  Future<void> createProject(Map<String,dynamic>d)=>api.post('/v1/projects',data:d);
  Future<void> createCertification(Map<String,dynamic>d)=>api.post('/v1/certifications',data:d);
  Future<void> createLanguage(Map<String,dynamic>d)=>api.post('/v1/languages',data:d);
  Future<void> saveSocialLinks(Map<String,dynamic>d)=>api.post('/v1/social-links',data:d);
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
  }) async {
    if (await hasResumeSelections(resumeId)) return;
    await saveResumeSelections(resumeId, {
      'skillIds': skillIds,
      'projectIds': projectIds,
      'experienceIds': experienceIds,
      'educationIds': educationIds,
      'certificationIds': certificationIds,
      'languageIds': languageIds,
    });
  }

  Future<List<int>> resumePdfBytes(int resumeId) => api.getBytes('/v1/resumes/$resumeId/pdf');

  Future<AtsAnalysis> atsAnalyze(int resumeId,String type,{String?jobTitle,String?jobDescription}) async { final r=await api.post('/v1/resumes/$resumeId/ats/analyze',data:{'analysisType':type,'jobTitle':jobTitle,'jobDescription':jobDescription}); return AtsAnalysis.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<AtsAnalysis> atsLatest(int resumeId) async { final r=await api.get('/v1/resumes/$resumeId/ats/latest'); return AtsAnalysis.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<List<AtsAnalysis>> atsHistory(int resumeId) async { final r=await api.get('/v1/resumes/$resumeId/ats/history'); return List<AtsAnalysis>.from((r.data as List).map((e)=>AtsAnalysis.fromJson(Map<String,dynamic>.from(e)))); }
  Future<SalaryEstimate> salaryEstimate(Map<String,dynamic>d) async { final r=await api.post('/v1/salary/estimate',data:d); return SalaryEstimate.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<SalaryCompare> salaryCompare(Map<String,dynamic>d) async { final r=await api.post('/v1/salary/compare',data:d); return SalaryCompare.fromJson(Map<String,dynamic>.from(r.data)); }
  Future<List<SalaryEstimate>> salaryHistory() async { final r=await api.get('/v1/salary/history'); return List<SalaryEstimate>.from((r.data as List).map((e)=>SalaryEstimate.fromJson(Map<String,dynamic>.from(e)))); }
}
