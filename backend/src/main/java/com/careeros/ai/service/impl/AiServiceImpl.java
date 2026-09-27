package com.careeros.ai.service.impl;

import com.careeros.ai.dto.CareerCoachRequest;
import com.careeros.ai.dto.CareerCoachResponse;
import com.careeros.ai.dto.GeminiSalaryEstimateRequest;
import com.careeros.ai.dto.GeminiSalaryEstimateResponse;
import com.careeros.ai.engine.CareerCoachOfflineEngine;
import com.careeros.ai.provider.AiProviderRouter;
import com.careeros.ai.service.AiService;
import com.careeros.experience.entity.Experience;
import com.careeros.skill.entity.Skill;
import com.careeros.user.entity.UserProfile;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class AiServiceImpl implements AiService {

    private final AiProviderRouter aiProviderRouter;
    private final ObjectMapper objectMapper;
    private final CareerCoachOfflineEngine careerCoachOfflineEngine;

    public AiServiceImpl(
            AiProviderRouter aiProviderRouter,
            ObjectMapper objectMapper,
            CareerCoachOfflineEngine careerCoachOfflineEngine
    ) {
        this.aiProviderRouter = aiProviderRouter;
        this.objectMapper = objectMapper;
        this.careerCoachOfflineEngine =
                careerCoachOfflineEngine;
    }

    @Override
    public String generateResponse(
            String prompt
    ) {

        validatePrompt(prompt);

        AiProviderRouter.ProviderResponse response =
                aiProviderRouter.generateText(
                        prompt
                );

        return response.content();
    }

    @Override
    public GeminiSalaryEstimateResponse estimateSalary(
            GeminiSalaryEstimateRequest request
    ) {

        validateSalaryRequest(request);

        String prompt =
                buildSalaryPrompt(request);

        AiProviderRouter.ProviderResponse providerResponse =
                aiProviderRouter.generateJson(
                        prompt
                );

        GeminiSalaryEstimateResponse response;

        try {

            response =
                    objectMapper.readValue(
                            providerResponse.content(),
                            GeminiSalaryEstimateResponse.class
                    );

        } catch (Exception exception) {

            throw new IllegalStateException(
                    "Failed to parse AI salary estimation response.",
                    exception
            );
        }

        validateSalaryResponse(response);

        response.setProvider(
                providerResponse.provider()
        );

        return response;
    }

    @Override
    public CareerCoachResponse careerCoach(
            CareerCoachRequest request,
            UserProfile profile,
            List<Skill> skills,
            List<Experience> experiences
    ) {

        validateCareerCoachRequest(
                request,
                profile
        );

        List<Skill> safeSkills =
                skills == null
                        ? List.of()
                        : skills;

        List<Experience> safeExperiences =
                experiences == null
                        ? List.of()
                        : experiences;

        /*
         * Always create a deterministic baseline.
         * This remains the final fallback.
         */
        CareerCoachResponse offlineResponse =
                careerCoachOfflineEngine.generateOfflineCoach(
                        request.getGoal(),
                        profile,
                        safeSkills,
                        safeExperiences
                );

        String prompt =
                buildCareerCoachPrompt(
                        request,
                        profile,
                        safeSkills,
                        safeExperiences,
                        offlineResponse
                );

        try {

            AiProviderRouter.ProviderResponse providerResponse =
                    aiProviderRouter.generateJson(
                            prompt
                    );

            CareerCoachResponse response =
                    objectMapper.readValue(
                            providerResponse.content(),
                            CareerCoachResponse.class
                    );

            validateCareerCoachResponse(
                    response
            );

            response.setSource(
                    providerResponse.provider()
            );

            return response;

        } catch (RuntimeException exception) {

            /*
             * All online providers failed.
             * Return the deterministic CareerOS roadmap.
             */
            offlineResponse.setSource(
                    "OFFLINE"
            );

            return offlineResponse;

        } catch (Exception exception) {

            offlineResponse.setSource(
                    "OFFLINE"
            );

            return offlineResponse;
        }
    }

    private String buildSalaryPrompt(
            GeminiSalaryEstimateRequest request
    ) {

        String skills =
                request.getSkills() == null
                        || request.getSkills().isEmpty()
                        ? "No specific skills provided."
                        : String.join(
                        ", ",
                        request.getSkills()
                );

        return """
                You are the salary estimation engine for CareerOS AI.

                Estimate a realistic current annual salary range
                for the following professional profile.

                Job Title: %s
                Location: %s
                Industry: %s
                Experience Years: %d
                Skills: %s

                Return ONLY valid JSON.

                Required JSON:
                {
                  "minimumSalary": 0,
                  "expectedSalary": 0,
                  "maximumSalary": 0,
                  "currency": "INR",
                  "factors": [
                    "factor 1",
                    "factor 2"
                  ]
                }

                Rules:
                1. Salary values must be annual.
                2. Use the local currency for the requested location.
                3. minimumSalary <= expectedSalary <= maximumSalary.
                4. Consider title, location, industry, experience and skills.
                5. Do not claim a guaranteed salary.
                6. Return realistic market ranges.
                7. Return numeric values without currency symbols.
                8. Do not return markdown or code fences.
                """.formatted(
                request.getJobTitle().trim(),
                request.getLocation().trim(),
                request.getIndustry().trim(),
                request.getExperienceYears(),
                skills
        );
    }

    private String buildCareerCoachPrompt(
            CareerCoachRequest request,
            UserProfile profile,
            List<Skill> skills,
            List<Experience> experiences,
            CareerCoachResponse baseline
    ) {

        String skillSummary =
                skills.stream()
                        .map(Skill::getSkillName)
                        .filter(this::hasText)
                        .map(String::trim)
                        .distinct()
                        .reduce(
                                "",
                                (current, value) ->
                                        current.isBlank()
                                                ? value
                                                : current + ", " + value
                        );

        String experienceSummary =
                experiences.stream()
                        .map(experience ->
                                safeText(
                                        experience.getJobTitle()
                                )
                                        + " at "
                                        + safeText(
                                        experience.getCompanyName()
                                )
                        )
                        .reduce(
                                "",
                                (current, value) ->
                                        current.isBlank()
                                                ? value
                                                : current + "; " + value
                        );

        return """
                You are the CareerOS AI Career Coach.

                Create a personalized career strategy using the user's
                actual CareerOS profile.

                USER GOAL:
                %s

                PROFILE:
                Current Job Title: %s
                Years of Experience: %s
                City: %s
                State: %s
                Country: %s

                SKILLS:
                %s

                EXPERIENCE:
                %s

                CAREEROS BASELINE:
                Assessment:
                %s

                Recommended Roles:
                %s

                Skill Gaps:
                %s

                Priority Skills:
                %s

                Improve and personalize the baseline.

                Return ONLY valid JSON.

                Required structure:
                {
                  "source": "AI",
                  "careerAssessment": "string",
                  "recommendedRoles": [
                    "string"
                  ],
                  "skillGaps": [
                    "string"
                  ],
                  "prioritySkills": [
                    "string"
                  ],
                  "roadmap": [
                    {
                      "phase": 1,
                      "title": "string",
                      "duration": "string",
                      "skills": [
                        "string"
                      ]
                    }
                  ],
                  "nextActions": [
                    "string"
                  ]
                }

                Rules:
                - Do not invent qualifications.
                - Use actual skills and experience.
                - Prioritize realistic career progression.
                - Keep roadmap phases actionable.
                - Match recommendations to the stated goal.
                - No markdown.
                - No code fences.
                """.formatted(
                safeText(request.getGoal()),
                safeText(profile.getCurrentJobTitle()),
                profile.getYearsOfExperience() == null
                        ? "Not provided"
                        : profile.getYearsOfExperience(),
                safeText(profile.getCity()),
                safeText(profile.getState()),
                safeText(profile.getCountry()),
                skillSummary.isBlank()
                        ? "No skills recorded"
                        : skillSummary,
                experienceSummary.isBlank()
                        ? "No experience recorded"
                        : experienceSummary,
                safeText(
                        baseline.getCareerAssessment()
                ),
                String.join(
                        ", ",
                        baseline.getRecommendedRoles()
                ),
                String.join(
                        ", ",
                        baseline.getSkillGaps()
                ),
                String.join(
                        ", ",
                        baseline.getPrioritySkills()
                )
        );
    }

    private void validateSalaryRequest(
            GeminiSalaryEstimateRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Salary estimation request must not be null."
            );
        }

        if (!hasText(request.getJobTitle())) {
            throw new IllegalArgumentException(
                    "Job title is required."
            );
        }

        if (!hasText(request.getLocation())) {
            throw new IllegalArgumentException(
                    "Location is required."
            );
        }

        if (!hasText(request.getIndustry())) {
            throw new IllegalArgumentException(
                    "Industry is required."
            );
        }

        if (request.getExperienceYears() == null
                || request.getExperienceYears() < 0) {

            throw new IllegalArgumentException(
                    "Experience years must be zero or greater."
            );
        }
    }

    private void validateCareerCoachRequest(
            CareerCoachRequest request,
            UserProfile profile
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Career coach request must not be null."
            );
        }

        if (!hasText(request.getGoal())) {
            throw new IllegalArgumentException(
                    "Career goal is required."
            );
        }

        if (profile == null) {
            throw new IllegalArgumentException(
                    "User profile is required for career coaching."
            );
        }
    }

    private void validateSalaryResponse(
            GeminiSalaryEstimateResponse response
    ) {

        if (response == null
                || response.getMinimumSalary() == null
                || response.getExpectedSalary() == null
                || response.getMaximumSalary() == null) {

            throw new IllegalStateException(
                    "AI returned incomplete salary information."
            );
        }

        BigDecimal minimum =
                response.getMinimumSalary();

        BigDecimal expected =
                response.getExpectedSalary();

        BigDecimal maximum =
                response.getMaximumSalary();

        if (minimum.compareTo(BigDecimal.ZERO) <= 0
                || expected.compareTo(BigDecimal.ZERO) <= 0
                || maximum.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalStateException(
                    "AI returned invalid salary values."
            );
        }

        if (minimum.compareTo(expected) > 0
                || expected.compareTo(maximum) > 0) {

            throw new IllegalStateException(
                    "AI returned an invalid salary range."
            );
        }

        if (!hasText(
                response.getCurrency()
        )) {

            throw new IllegalStateException(
                    "AI did not return a salary currency."
            );
        }

        if (response.getFactors() == null) {
            response.setFactors(
                    new ArrayList<>()
            );
        }
    }

    private void validateCareerCoachResponse(
            CareerCoachResponse response
    ) {

        if (response == null) {
            throw new IllegalStateException(
                    "AI returned an empty Career Coach response."
            );
        }

        if (!hasText(
                response.getCareerAssessment()
        )) {

            throw new IllegalStateException(
                    "Career assessment is missing."
            );
        }

        if (response.getRecommendedRoles() == null) {
            response.setRecommendedRoles(
                    new ArrayList<>()
            );
        }

        if (response.getSkillGaps() == null) {
            response.setSkillGaps(
                    new ArrayList<>()
            );
        }

        if (response.getPrioritySkills() == null) {
            response.setPrioritySkills(
                    new ArrayList<>()
            );
        }

        if (response.getRoadmap() == null) {
            response.setRoadmap(
                    new ArrayList<>()
            );
        }

        if (response.getNextActions() == null) {
            response.setNextActions(
                    new ArrayList<>()
            );
        }
    }

    private void validatePrompt(
            String prompt
    ) {

        if (!hasText(prompt)) {
            throw new IllegalArgumentException(
                    "AI prompt must not be blank."
            );
        }
    }

    private boolean hasText(
            String value
    ) {

        return value != null
                && !value.trim().isEmpty();
    }

    private String safeText(
            String value
    ) {

        return hasText(value)
                ? value.trim()
                : "Not provided";
    }
}