package com.careeros.template.service.impl;

import com.careeros.education.repository.EducationRepository;
import com.careeros.experience.repository.ExperienceRepository;
import com.careeros.project.repository.ProjectRepository;
import com.careeros.resume.entity.Resume;
import com.careeros.resume.repository.ResumeRepository;
import com.careeros.resumeselection.entity.ResumeSelection;
import com.careeros.resumeselection.repository.ResumeSelectionRepository;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.skill.repository.SkillRepository;
import com.careeros.certification.repository.CertificationRepository;
import com.careeros.language.repository.LanguageRepository;
import com.careeros.sociallinks.repository.SocialLinksRepository;
import com.careeros.template.service.TemplateService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
@Transactional(readOnly = true)
public class TemplateServiceImpl implements TemplateService {

    private final TemplateEngine templateEngine;

    private final ResumeRepository resumeRepository;
    private final ResumeSelectionRepository resumeSelectionRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    private final EducationRepository educationRepository;
    private final ExperienceRepository experienceRepository;
    private final SkillRepository skillRepository;
    private final ProjectRepository projectRepository;
    private final CertificationRepository certificationRepository;
    private final LanguageRepository languageRepository;
    private final SocialLinksRepository socialLinksRepository;

    public TemplateServiceImpl(
            TemplateEngine templateEngine,
            ResumeRepository resumeRepository,
            ResumeSelectionRepository resumeSelectionRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService,
            EducationRepository educationRepository,
            ExperienceRepository experienceRepository,
            SkillRepository skillRepository,
            ProjectRepository projectRepository,
            CertificationRepository certificationRepository,
            LanguageRepository languageRepository,
            SocialLinksRepository socialLinksRepository
    ) {
        this.templateEngine = templateEngine;
        this.resumeRepository = resumeRepository;
        this.resumeSelectionRepository = resumeSelectionRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
        this.educationRepository = educationRepository;
        this.experienceRepository = experienceRepository;
        this.skillRepository = skillRepository;
        this.projectRepository = projectRepository;
        this.certificationRepository = certificationRepository;
        this.languageRepository = languageRepository;
        this.socialLinksRepository = socialLinksRepository;
    }

    @Override
    public String generateResumeHtml(Long resumeId) {

        /*
         * 1. Get the authenticated user's profile
         */
        UserProfile profile = getCurrentUserProfile();

        /*
         * 2. Get the resume and verify ownership
         */
        Resume resume = resumeRepository
                .findByIdAndUserProfile(resumeId, profile)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Resume does not belong to the authenticated user."
                        )
                );

        /*
         * 3. Get selections for this exact resume
         */
        ResumeSelection selection = resumeSelectionRepository
                .findByResume(resume)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Resume selections not found."
                        )
                );

        /*
         * 4. Create Thymeleaf context
         */
        Context context = new Context();

        /*
         * 5. Basic resume information
         */
        context.setVariable("resume", resume);
        context.setVariable("profile", profile);
        context.setVariable("user", profile.getUser());

        /*
         * 6. Selected education
         */
        context.setVariable(
                "educations",
                educationRepository.findAllById(
                        selection.getEducationIds()
                )
        );

        /*
         * 7. Selected experiences
         */
        context.setVariable(
                "experiences",
                experienceRepository.findAllById(
                        selection.getExperienceIds()
                )
        );

        /*
         * 8. Selected skills
         */
        context.setVariable(
                "skills",
                skillRepository.findAllById(
                        selection.getSkillIds()
                )
        );

        /*
         * 9. Selected projects
         */
        context.setVariable(
                "projects",
                projectRepository.findAllById(
                        selection.getProjectIds()
                )
        );

        /*
         * 10. Selected certifications
         */
        context.setVariable(
                "certifications",
                certificationRepository.findAllById(
                        selection.getCertificationIds()
                )
        );

        /*
         * 11. Selected languages
         */
        context.setVariable(
                "languages",
                languageRepository.findAllById(
                        selection.getLanguageIds()
                )
        );

        /*
         * 12. Social links
         *
         * Social links are not part of ResumeSelection,
         * so the user's social links are included.
         */
        context.setVariable(
                "socialLinks",
                socialLinksRepository
                        .findByUserProfile(profile)
                        .orElse(null)
        );

        /*
         * 13. Render Thymeleaf template
         */
        return templateEngine.process(
                "modern",
                context
        );
    }

    /*
     * Get currently authenticated user's profile.
     */
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
}