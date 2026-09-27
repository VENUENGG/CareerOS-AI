package com.careeros.ats.service.impl;

import com.careeros.ats.dto.AtsAnalysisRequest;
import com.careeros.ats.dto.AtsAnalysisResponse;
import com.careeros.ats.engine.AtsEngine;
import com.careeros.ats.engine.AtsEngineInput;
import com.careeros.ats.engine.AtsEngineResult;
import com.careeros.ats.entity.AtsAnalysis;
import com.careeros.ats.entity.AtsAnalysisType;
import com.careeros.ats.mapper.AtsAnalysisMapper;
import com.careeros.ats.repository.AtsAnalysisRepository;
import com.careeros.certification.entity.Certification;
import com.careeros.certification.repository.CertificationRepository;
import com.careeros.education.entity.Education;
import com.careeros.education.repository.EducationRepository;
import com.careeros.exception.ResumeNotFoundException;
import com.careeros.exception.ResumeSelectionNotFoundException;
import com.careeros.experience.entity.Experience;
import com.careeros.experience.repository.ExperienceRepository;
import com.careeros.language.entity.Language;
import com.careeros.language.repository.LanguageRepository;
import com.careeros.project.entity.Project;
import com.careeros.project.repository.ProjectRepository;
import com.careeros.resume.entity.Resume;
import com.careeros.resume.repository.ResumeRepository;
import com.careeros.resumeselection.entity.ResumeSelection;
import com.careeros.resumeselection.repository.ResumeSelectionRepository;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.skill.entity.Skill;
import com.careeros.skill.repository.SkillRepository;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@Transactional
public class AtsAnalysisServiceImpl implements com.careeros.ats.service.AtsAnalysisService {

    private final AtsAnalysisRepository atsAnalysisRepository;
    private final ResumeRepository resumeRepository;
    private final ResumeSelectionRepository resumeSelectionRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    private final SkillRepository skillRepository;
    private final ExperienceRepository experienceRepository;
    private final EducationRepository educationRepository;
    private final ProjectRepository projectRepository;
    private final CertificationRepository certificationRepository;
    private final LanguageRepository languageRepository;

    private final AtsEngine atsEngine;

    public AtsAnalysisServiceImpl(
            AtsAnalysisRepository atsAnalysisRepository,
            ResumeRepository resumeRepository,
            ResumeSelectionRepository resumeSelectionRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService,
            SkillRepository skillRepository,
            ExperienceRepository experienceRepository,
            EducationRepository educationRepository,
            ProjectRepository projectRepository,
            CertificationRepository certificationRepository,
            LanguageRepository languageRepository,
            AtsEngine atsEngine
    ) {
        this.atsAnalysisRepository = atsAnalysisRepository;
        this.resumeRepository = resumeRepository;
        this.resumeSelectionRepository = resumeSelectionRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
        this.skillRepository = skillRepository;
        this.experienceRepository = experienceRepository;
        this.educationRepository = educationRepository;
        this.projectRepository = projectRepository;
        this.certificationRepository = certificationRepository;
        this.languageRepository = languageRepository;
        this.atsEngine = atsEngine;
    }

    @Override
    public AtsAnalysisResponse analyzeResume(
            Long resumeId,
            AtsAnalysisRequest request
    ) {

        validateRequest(request);

        UserProfile profile =
                getCurrentUserProfile();

        Resume resume =
                resumeRepository
                        .findByIdAndUserProfile(
                                resumeId,
                                profile
                        )
                        .orElseThrow(() ->
                                new ResumeNotFoundException(
                                        "Resume does not belong to the authenticated user."
                                )
                        );

        ResumeSelection selection =
                resumeSelectionRepository
                        .findByResume(resume)
                        .orElseThrow(() ->
                                new ResumeSelectionNotFoundException(
                                        "Resume selections not found. "
                                                + "Please select resume content before running ATS analysis."
                                )
                        );

        AtsEngineInput input =
                buildEngineInput(
                        resume,
                        selection,
                        request
                );

        AtsEngineResult result =
                atsEngine.analyze(input);

        AtsAnalysis analysis =
                new AtsAnalysis();

        analysis.setResume(resume);
        analysis.setAnalysisType(
                request.getAnalysisType()
        );

        analysis.setAtsScore(
                result.getAtsScore()
        );

        analysis.setKeywordScore(
                result.getKeywordScore()
        );

        analysis.setSkillsScore(
                result.getSkillsScore()
        );

        analysis.setExperienceScore(
                result.getExperienceScore()
        );

        analysis.setEducationScore(
                result.getEducationScore()
        );

        analysis.setFormattingScore(
                result.getFormattingScore()
        );

        if (request.getAnalysisType()
                == AtsAnalysisType.JOB_SPECIFIC) {

            analysis.setJobTitle(
                    clean(request.getJobTitle())
            );

            analysis.setJobDescription(
                    clean(request.getJobDescription())
            );

        } else {

            analysis.setJobTitle(null);
            analysis.setJobDescription(null);
        }

        analysis.setMatchedKeywords(
                new ArrayList<>(
                        result.getMatchedKeywords()
                )
        );

        analysis.setMissingKeywords(
                new ArrayList<>(
                        result.getMissingKeywords()
                )
        );

        analysis.setStrengths(
                new ArrayList<>(
                        result.getStrengths()
                )
        );

        analysis.setWeaknesses(
                new ArrayList<>(
                        result.getWeaknesses()
                )
        );

        analysis.setSuggestions(
                new ArrayList<>(
                        result.getSuggestions()
                )
        );

        AtsAnalysis saved =
                atsAnalysisRepository.save(
                        analysis
                );

        return AtsAnalysisMapper.toResponse(
                saved
        );
    }

    @Override
    @Transactional(readOnly = true)
    public AtsAnalysisResponse getLatestAnalysis(
            Long resumeId
    ) {

        Resume resume =
                getOwnedResume(resumeId);

        AtsAnalysis analysis =
                atsAnalysisRepository
                        .findFirstByResumeOrderByCreatedAtDesc(
                                resume
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "No ATS analysis found for this resume."
                                )
                        );

        return AtsAnalysisMapper.toResponse(
                analysis
        );
    }

    @Override
    @Transactional(readOnly = true)
    public List<AtsAnalysisResponse> getAnalysisHistory(
            Long resumeId
    ) {

        Resume resume =
                getOwnedResume(resumeId);

        List<AtsAnalysis> analyses =
                atsAnalysisRepository
                        .findByResumeOrderByCreatedAtDesc(
                                resume
                        );

        return analyses.stream()
                .map(AtsAnalysisMapper::toResponse)
                .toList();
    }

    private AtsEngineInput buildEngineInput(
            Resume resume,
            ResumeSelection selection,
            AtsAnalysisRequest request
    ) {

        AtsEngineInput input =
                new AtsEngineInput();

        input.setResumeTitle(
                resume.getTitle()
        );

        input.setProfessionalSummary(
                resume.getProfessionalSummary()
        );

        input.setHeadline(
                getCurrentUserProfile()
                        .getHeadline()
        );

        if (request.getAnalysisType()
                == AtsAnalysisType.JOB_SPECIFIC) {

            input.setJobTitle(
                    clean(request.getJobTitle())
            );

            input.setJobDescription(
                    clean(request.getJobDescription())
            );
        }

        /*
         * Selected Skills
         */
        input.setSkills(
                buildSkills(
                        selection.getSkillIds(),
                        getCurrentUserProfile()
                )
        );

        /*
         * Selected Experiences
         */
        input.setExperiences(
                buildExperiences(
                        selection.getExperienceIds(),
                        getCurrentUserProfile()
                )
        );

        /*
         * Selected Education
         */
        input.setEducation(
                buildEducation(
                        selection.getEducationIds(),
                        getCurrentUserProfile()
                )
        );

        /*
         * Selected Projects
         */
        input.setProjects(
                buildProjects(
                        selection.getProjectIds(),
                        getCurrentUserProfile()
                )
        );

        /*
         * Selected Certifications
         */
        input.setCertifications(
                buildCertifications(
                        selection.getCertificationIds(),
                        getCurrentUserProfile()
                )
        );

        /*
         * Selected Languages
         */
        input.setLanguages(
                buildLanguages(
                        selection.getLanguageIds(),
                        getCurrentUserProfile()
                )
        );

        return input;
    }

    private List<String> buildSkills(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Skill skill =
                    skillRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected skill does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            values.add(
                    skill.getSkillName()
                            + " "
                            + skill.getProficiency()
            );
        }

        return values;
    }

    private List<String> buildExperiences(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Experience experience =
                    experienceRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected experience does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            StringBuilder text =
                    new StringBuilder();

            append(
                    text,
                    experience.getJobTitle()
            );

            append(
                    text,
                    experience.getCompanyName()
            );

            append(
                    text,
                    experience.getEmploymentType()
            );

            append(
                    text,
                    experience.getLocation()
            );

            append(
                    text,
                    experience.getDescription()
            );

            append(
                    text,
                    experience.getStartDate()
            );

            append(
                    text,
                    experience.getEndDate()
            );

            values.add(
                    text.toString()
            );
        }

        return values;
    }

    private List<String> buildEducation(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Education education =
                    educationRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected education does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            StringBuilder text =
                    new StringBuilder();

            append(
                    text,
                    education.getDegree()
            );

            append(
                    text,
                    education.getFieldOfStudy()
            );

            append(
                    text,
                    education.getInstitutionName()
            );

            append(
                    text,
                    education.getGrade()
            );

            append(
                    text,
                    education.getDescription()
            );

            values.add(
                    text.toString()
            );
        }

        return values;
    }

    private List<String> buildProjects(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Project project =
                    projectRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected project does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            StringBuilder text =
                    new StringBuilder();

            append(
                    text,
                    project.getProjectName()
            );

            append(
                    text,
                    project.getDescription()
            );

            append(
                    text,
                    project.getTechnologies()
            );

            values.add(
                    text.toString()
            );
        }

        return values;
    }

    private List<String> buildCertifications(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Certification certification =
                    certificationRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected certification does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            StringBuilder text =
                    new StringBuilder();

            append(
                    text,
                    certification.getCertificationName()
            );

            append(
                    text,
                    certification.getIssuingOrganization()
            );

            append(
                    text,
                    certification.getCredentialId()
            );

            values.add(
                    text.toString()
            );
        }

        return values;
    }

    private List<String> buildLanguages(
            java.util.Set<Long> ids,
            UserProfile profile
    ) {

        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> values =
                new ArrayList<>();

        for (Long id : ids) {

            if (id == null) {
                continue;
            }

            Language language =
                    languageRepository
                            .findByIdAndUserProfile(
                                    id,
                                    profile
                            )
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Selected language does not belong to the authenticated user: "
                                                    + id
                                    )
                            );

            values.add(
                    language.getLanguageName()
                            + " "
                            + language.getProficiency()
            );
        }

        return values;
    }

    private Resume getOwnedResume(
            Long resumeId
    ) {

        UserProfile profile =
                getCurrentUserProfile();

        return resumeRepository
                .findByIdAndUserProfile(
                        resumeId,
                        profile
                )
                .orElseThrow(() ->
                        new ResumeNotFoundException(
                                "Resume does not belong to the authenticated user."
                        )
                );
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser =
                authenticatedUserService.getCurrentUser();

        return userProfileRepository
                .findByUser(currentUser)
                .orElseThrow(() ->
                        new RuntimeException(
                                "User profile not found."
                        )
                );
    }

    private void validateRequest(
            AtsAnalysisRequest request
    ) {

        if (request == null) {

            throw new IllegalArgumentException(
                    "ATS analysis request must not be null."
            );
        }

        if (request.getAnalysisType() == null) {

            throw new IllegalArgumentException(
                    "Analysis type is required."
            );
        }

        if (request.getAnalysisType()
                == AtsAnalysisType.JOB_SPECIFIC
                && !hasText(
                request.getJobDescription()
        )) {

            throw new IllegalArgumentException(
                    "Job description is required for job-specific ATS analysis."
            );
        }

        if (request.getAnalysisType()
                == AtsAnalysisType.GENERAL) {

            request.setJobTitle(null);
            request.setJobDescription(null);
        }
    }

    private void append(
            StringBuilder builder,
            Object value
    ) {

        if (value == null) {
            return;
        }

        String text =
                value.toString().trim();

        if (text.isEmpty()) {
            return;
        }

        if (!builder.isEmpty()) {
            builder.append(' ');
        }

        builder.append(text);
    }

    private String clean(
            String value
    ) {

        if (!hasText(value)) {
            return null;
        }

        return value.trim();
    }

    private boolean hasText(
            String value
    ) {

        return value != null
                && !value.trim().isEmpty();
    }
}