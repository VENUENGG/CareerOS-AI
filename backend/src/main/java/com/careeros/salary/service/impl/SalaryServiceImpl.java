package com.careeros.salary.service.impl;

import com.careeros.ai.dto.GeminiSalaryEstimateRequest;
import com.careeros.ai.dto.GeminiSalaryEstimateResponse;
import com.careeros.ai.service.AiService;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.salary.dto.SalaryCompareRequest;
import com.careeros.salary.dto.SalaryCompareResponse;
import com.careeros.salary.dto.SalaryEstimateRequest;
import com.careeros.salary.dto.SalaryEstimateResponse;
import com.careeros.salary.engine.SalaryEstimationEngine;
import com.careeros.salary.entity.SalaryAnalysis;
import com.careeros.salary.entity.SalaryBenchmark;
import com.careeros.salary.entity.SalarySkillPremium;
import com.careeros.salary.mapper.SalaryAnalysisMapper;
import com.careeros.salary.repository.SalaryAnalysisRepository;
import com.careeros.salary.repository.SalaryBenchmarkRepository;
import com.careeros.salary.repository.SalarySkillPremiumRepository;
import com.careeros.salary.service.SalaryService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.skill.entity.Skill;
import com.careeros.skill.repository.SkillRepository;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
public class SalaryServiceImpl implements SalaryService {

    private final SalaryAnalysisRepository salaryAnalysisRepository;
    private final SalaryBenchmarkRepository salaryBenchmarkRepository;
    private final SalarySkillPremiumRepository salarySkillPremiumRepository;
    private final SkillRepository skillRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;
    private final SalaryEstimationEngine salaryEstimationEngine;
    private final AiService aiService;

    public SalaryServiceImpl(
            SalaryAnalysisRepository salaryAnalysisRepository,
            SalaryBenchmarkRepository salaryBenchmarkRepository,
            SalarySkillPremiumRepository salarySkillPremiumRepository,
            SkillRepository skillRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService,
            SalaryEstimationEngine salaryEstimationEngine,
            AiService aiService
    ) {
        this.salaryAnalysisRepository = salaryAnalysisRepository;
        this.salaryBenchmarkRepository = salaryBenchmarkRepository;
        this.salarySkillPremiumRepository = salarySkillPremiumRepository;
        this.skillRepository = skillRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
        this.salaryEstimationEngine = salaryEstimationEngine;
        this.aiService = aiService;
    }

    @Override
    public SalaryEstimateResponse estimateSalary(
            SalaryEstimateRequest request
    ) {

        validateRequest(request);

        UserProfile profile = getCurrentUserProfile();

        validateExperienceConsistency(
                request,
                profile
        );

        List<Skill> skills =
                getOwnedSkills(
                        request.getSkillIds(),
                        profile
                );

        String jobTitle =
                request.getJobTitle().trim();

        String location =
                request.getLocation().trim();

        String industry =
                request.getIndustry().trim();

        int experienceYears =
                request.getExperienceYears();

        Optional<SalaryBenchmark> benchmarkOptional =
                salaryBenchmarkRepository
                        .findByJobTitleIgnoreCaseAndLocationIgnoreCaseAndExperienceLevelIgnoreCaseAndIndustryIgnoreCase(
                                jobTitle,
                                location,
                                determineExperienceLevel(
                                        experienceYears
                                ),
                                industry
                        );

        BigDecimal minimumSalary;
        BigDecimal expectedSalary;
        BigDecimal maximumSalary;
        String currency;
        List<String> factors;

        if (benchmarkOptional.isPresent()) {

            SalaryBenchmark benchmark =
                    benchmarkOptional.get();

            List<SalarySkillPremium> premiums =
                    getApplicableSkillPremiums(
                            benchmark.getJobTitle(),
                            skills
                    );

            SalaryEstimationEngine.SalaryResult result =
                    salaryEstimationEngine.estimate(
                            benchmark,
                            premiums,
                            experienceYears
                    );

            minimumSalary =
                    result.minimumSalary();

            expectedSalary =
                    result.expectedSalary();

            maximumSalary =
                    result.maximumSalary();

            currency =
                    benchmark.getCurrency();

            factors =
                    new ArrayList<>(
                            result.factors()
                    );

        } else {

            GeminiSalaryEstimateResponse aiResult =
                    getAiSalaryEstimate(
                            jobTitle,
                            location,
                            industry,
                            experienceYears,
                            skills
                    );

            minimumSalary =
                    normalizeSalary(
                            aiResult.getMinimumSalary()
                    );

            expectedSalary =
                    normalizeSalary(
                            aiResult.getExpectedSalary()
                    );

            maximumSalary =
                    normalizeSalary(
                            aiResult.getMaximumSalary()
                    );

            currency =
                    normalizeCurrency(
                            aiResult.getCurrency()
                    );

            factors =
                    aiResult.getFactors() == null
                            ? new ArrayList<>()
                            : new ArrayList<>(
                            aiResult.getFactors()
                    );

            factors.add(
                    "No local CareerOS benchmark was available; "
                            + "Gemini market research was used."
            );

            validateSalaryRange(
                    minimumSalary,
                    expectedSalary,
                    maximumSalary
            );
        }

        String marketPosition =
                determineMarketPosition(
                        request.getCurrentSalary(),
                        expectedSalary
                );

        SalaryAnalysis analysis =
                new SalaryAnalysis();

        analysis.setUserProfile(profile);
        analysis.setJobTitle(jobTitle);
        analysis.setLocation(location);
        analysis.setIndustry(industry);
        analysis.setExperienceYears(experienceYears);

        analysis.setMinimumSalary(
                minimumSalary
        );

        analysis.setExpectedSalary(
                expectedSalary
        );

        analysis.setMaximumSalary(
                maximumSalary
        );

        analysis.setCurrency(currency);

        analysis.setCurrentSalary(
                request.getCurrentSalary()
        );

        analysis.setMarketPosition(
                marketPosition
        );

        analysis.setFactors(
                new HashSet<>(factors)
        );

        analysis.setSkillNames(
                skills.stream()
                        .map(Skill::getSkillName)
                        .filter(this::hasText)
                        .map(String::trim)
                        .collect(Collectors.toSet())
        );

        SalaryAnalysis saved =
                salaryAnalysisRepository.save(
                        analysis
                );

        return SalaryAnalysisMapper.mapToResponse(
                saved
        );
    }

    @Override
    public SalaryCompareResponse compareSalary(
            SalaryCompareRequest request
    ) {

        validateCompareRequest(request);

        SalaryEstimateRequest estimateRequest =
                request.getEstimate();

        estimateRequest.setCurrentSalary(
                request.getCurrentSalary()
        );

        SalaryEstimateResponse estimate =
                estimateSalary(
                        estimateRequest
                );

        BigDecimal currentSalary =
                request.getCurrentSalary();

        BigDecimal expectedSalary =
                estimate.getExpectedSalary();

        if (expectedSalary == null
                || expectedSalary.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalStateException(
                    "Expected salary must be greater than zero."
            );
        }

        BigDecimal difference =
                currentSalary
                        .subtract(expectedSalary)
                        .setScale(
                                2,
                                RoundingMode.HALF_UP
                        );

        BigDecimal percentageDifference =
                difference
                        .divide(
                                expectedSalary,
                                6,
                                RoundingMode.HALF_UP
                        )
                        .multiply(
                                BigDecimal.valueOf(100)
                        )
                        .setScale(
                                2,
                                RoundingMode.HALF_UP
                        );

        String marketPosition =
                determineMarketPosition(
                        currentSalary,
                        expectedSalary
                );

        SalaryCompareResponse response =
                new SalaryCompareResponse();

        response.setCurrentSalary(
                currentSalary
        );

        response.setExpectedSalary(
                expectedSalary
        );

        response.setMinimumSalary(
                estimate.getMinimumSalary()
        );

        response.setMaximumSalary(
                estimate.getMaximumSalary()
        );

        response.setDifferenceFromExpected(
                difference
        );

        response.setPercentageDifference(
                percentageDifference
        );

        response.setMarketPosition(
                marketPosition
        );

        response.setMessage(
                createComparisonMessage(
                        marketPosition
                )
        );

        response.setEstimate(
                estimate
        );

        return response;
    }

    @Override
    @Transactional(readOnly = true)
    public SalaryEstimateResponse getLatestSalaryAnalysis() {

        UserProfile profile =
                getCurrentUserProfile();

        SalaryAnalysis analysis =
                salaryAnalysisRepository
                        .findTopByUserProfileOrderByCreatedAtDesc(
                                profile
                        )
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "No salary analysis found."
                                )
                        );

        return SalaryAnalysisMapper.mapToResponse(
                analysis
        );
    }

    @Override
    @Transactional(readOnly = true)
    public List<SalaryEstimateResponse> getSalaryHistory() {

        UserProfile profile =
                getCurrentUserProfile();

        return salaryAnalysisRepository
                .findAllByUserProfileOrderByCreatedAtDesc(
                        profile
                )
                .stream()
                .map(SalaryAnalysisMapper::mapToResponse)
                .toList();
    }

    private GeminiSalaryEstimateResponse getAiSalaryEstimate(
            String jobTitle,
            String location,
            String industry,
            int experienceYears,
            List<Skill> skills
    ) {

        GeminiSalaryEstimateRequest request =
                new GeminiSalaryEstimateRequest();

        request.setJobTitle(jobTitle);
        request.setLocation(location);
        request.setIndustry(industry);
        request.setExperienceYears(
                experienceYears
        );

        request.setSkills(
                skills.stream()
                        .map(Skill::getSkillName)
                        .filter(this::hasText)
                        .map(String::trim)
                        .distinct()
                        .toList()
        );

        GeminiSalaryEstimateResponse response =
                aiService.estimateSalary(
                        request
                );

        if (response == null) {
            throw new IllegalStateException(
                    "AI salary estimation returned no response."
            );
        }

        return response;
    }

    private List<Skill> getOwnedSkills(
            Set<Long> skillIds,
            UserProfile profile
    ) {

        if (skillIds == null || skillIds.isEmpty()) {
            return new ArrayList<>();
        }

        Set<Long> cleanedIds =
                skillIds.stream()
                        .filter(id -> id != null)
                        .collect(Collectors.toSet());

        if (cleanedIds.isEmpty()) {
            return new ArrayList<>();
        }

        List<Skill> skills =
                skillRepository.findAllById(
                        cleanedIds
                );

        if (skills.size() != cleanedIds.size()) {
            throw new IllegalArgumentException(
                    "One or more selected skills do not exist."
            );
        }

        for (Skill skill : skills) {

            if (skill.getUserProfile() == null
                    || skill.getUserProfile().getId() == null
                    || !skill.getUserProfile()
                    .getId()
                    .equals(profile.getId())) {

                throw new IllegalArgumentException(
                        "Selected skill does not belong to the authenticated user: "
                                + skill.getId()
                );
            }
        }

        return skills;
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser =
                authenticatedUserService.getCurrentUser();

        return userProfileRepository
                .findByUser(currentUser)
                .orElseThrow(() ->
                        new UserProfileNotFoundException(
                                "User profile not found."
                        )
                );
    }

    private void validateRequest(
            SalaryEstimateRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Salary estimate request must not be null."
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

        if (request.getExperienceYears() == null) {
            throw new IllegalArgumentException(
                    "Experience years is required."
            );
        }

        if (request.getExperienceYears() < 0) {
            throw new IllegalArgumentException(
                    "Experience years cannot be negative."
            );
        }

        if (request.getExperienceYears() > 50) {
            throw new IllegalArgumentException(
                    "Experience years cannot exceed 50."
            );
        }

        if (request.getCurrentSalary() != null
                && request.getCurrentSalary()
                .compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Current salary must be greater than zero."
            );
        }
    }

    private void validateCompareRequest(
            SalaryCompareRequest request
    ) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Salary comparison request must not be null."
            );
        }

        if (request.getCurrentSalary() == null
                || request.getCurrentSalary()
                .compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "Current salary must be greater than zero."
            );
        }

        if (request.getEstimate() == null) {
            throw new IllegalArgumentException(
                    "Salary estimate details are required."
            );
        }
    }

    private void validateExperienceConsistency(
            SalaryEstimateRequest request,
            UserProfile profile
    ) {

        if (profile.getYearsOfExperience() == null) {
            return;
        }

        if (profile.getYearsOfExperience() < 0) {
            return;
        }

        /*
         * We allow the user to estimate a target role
         * with different experience when planning a future career.
         *
         * Therefore we do not reject reasonable differences.
         */
    }

    private List<SalarySkillPremium> getApplicableSkillPremiums(
            String jobTitle,
            List<Skill> skills
    ) {

        if (skills.isEmpty()) {
            return new ArrayList<>();
        }

        List<SalarySkillPremium> premiums =
                salarySkillPremiumRepository
                        .findByJobTitleIgnoreCase(
                                jobTitle
                        );

        if (premiums.isEmpty()) {
            return new ArrayList<>();
        }

        Set<String> selectedSkillNames =
                skills.stream()
                        .map(Skill::getSkillName)
                        .filter(this::hasText)
                        .map(skill ->
                                skill.trim()
                                        .toLowerCase()
                        )
                        .collect(Collectors.toSet());

        return premiums.stream()
                .filter(premium ->
                        premium.getSkillName() != null
                                && selectedSkillNames.contains(
                                premium.getSkillName()
                                        .trim()
                                        .toLowerCase()
                        )
                )
                .toList();
    }

    private String determineExperienceLevel(
            int years
    ) {

        if (years <= 1) {
            return "ENTRY";
        }

        if (years <= 3) {
            return "JUNIOR";
        }

        if (years <= 6) {
            return "MID";
        }

        if (years <= 10) {
            return "SENIOR";
        }

        return "LEAD";
    }

    private String determineMarketPosition(
            BigDecimal currentSalary,
            BigDecimal expectedSalary
    ) {

        if (currentSalary == null) {
            return "NOT_PROVIDED";
        }

        if (expectedSalary == null
                || expectedSalary.compareTo(BigDecimal.ZERO) <= 0) {

            return "NOT_AVAILABLE";
        }

        BigDecimal lowerThreshold =
                expectedSalary.multiply(
                        BigDecimal.valueOf(0.90)
                );

        BigDecimal upperThreshold =
                expectedSalary.multiply(
                        BigDecimal.valueOf(1.10)
                );

        if (currentSalary.compareTo(lowerThreshold) < 0) {
            return "BELOW_MARKET";
        }

        if (currentSalary.compareTo(upperThreshold) > 0) {
            return "ABOVE_MARKET";
        }

        return "MARKET_ALIGNED";
    }

    private String createComparisonMessage(
            String position
    ) {

        return switch (position) {

            case "BELOW_MARKET" ->
                    "Your current salary is below the estimated market expectation for this profile.";

            case "ABOVE_MARKET" ->
                    "Your current salary is above the estimated market expectation for this profile.";

            case "MARKET_ALIGNED" ->
                    "Your current salary is broadly aligned with the estimated market expectation.";

            case "NOT_AVAILABLE" ->
                    "Market comparison is unavailable for this estimate.";

            default ->
                    "Current salary was not provided.";
        };
    }

    private BigDecimal normalizeSalary(
            BigDecimal salary
    ) {

        if (salary == null) {
            throw new IllegalStateException(
                    "Salary value must not be null."
            );
        }

        return salary.setScale(
                0,
                RoundingMode.HALF_UP
        );
    }

    private String normalizeCurrency(
            String currency
    ) {

        if (!hasText(currency)) {
            throw new IllegalStateException(
                    "Salary currency is required."
            );
        }

        return currency
                .trim()
                .toUpperCase();
    }

    private void validateSalaryRange(
            BigDecimal minimum,
            BigDecimal expected,
            BigDecimal maximum
    ) {

        if (minimum.compareTo(BigDecimal.ZERO) <= 0
                || expected.compareTo(BigDecimal.ZERO) <= 0
                || maximum.compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalStateException(
                    "Salary values must be greater than zero."
            );
        }

        if (minimum.compareTo(expected) > 0) {

            throw new IllegalStateException(
                    "Minimum salary cannot exceed expected salary."
            );
        }

        if (expected.compareTo(maximum) > 0) {

            throw new IllegalStateException(
                    "Expected salary cannot exceed maximum salary."
            );
        }
    }

    private boolean hasText(
            String value
    ) {

        return value != null
                && !value.trim().isEmpty();
    }
}