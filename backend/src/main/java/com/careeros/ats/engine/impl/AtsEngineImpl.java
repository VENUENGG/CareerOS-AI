package com.careeros.ats.engine.impl;

import com.careeros.ats.engine.AtsEngine;
import com.careeros.ats.engine.AtsEngineInput;
import com.careeros.ats.engine.AtsEngineResult;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Component
public class AtsEngineImpl implements AtsEngine {

    private static final Pattern NON_ALPHANUMERIC =
            Pattern.compile("[^a-z0-9+#.]");

    private static final Set<String> STOP_WORDS =
            Set.of(
                    "a",
                    "an",
                    "and",
                    "are",
                    "as",
                    "at",
                    "be",
                    "by",
                    "for",
                    "from",
                    "has",
                    "have",
                    "in",
                    "into",
                    "is",
                    "it",
                    "of",
                    "on",
                    "or",
                    "that",
                    "the",
                    "their",
                    "this",
                    "to",
                    "using",
                    "with",
                    "will",
                    "you",
                    "your"
            );

    private static final Set<String> TECHNICAL_KEYWORDS =
            Set.of(
                    "java",
                    "spring",
                    "spring boot",
                    "spring security",
                    "spring data",
                    "hibernate",
                    "jpa",
                    "postgresql",
                    "mysql",
                    "mongodb",
                    "redis",
                    "docker",
                    "kubernetes",
                    "aws",
                    "azure",
                    "gcp",
                    "git",
                    "github",
                    "maven",
                    "gradle",
                    "microservices",
                    "rest",
                    "rest api",
                    "api",
                    "jwt",
                    "oauth",
                    "sql",
                    "nosql",
                    "linux",
                    "terraform",
                    "jenkins",
                    "kafka",
                    "rabbitmq",
                    "python",
                    "javascript",
                    "typescript",
                    "react",
                    "flutter",
                    "dart",
                    "c++",
                    "c#",
                    "go",
                    "rust"
            );

    @Override
    public AtsEngineResult analyze(
            AtsEngineInput input
    ) {

        validateInput(input);

        AtsEngineResult result =
                new AtsEngineResult();

        String resumeText =
                buildResumeText(input);

        boolean jobSpecific =
                hasText(input.getJobDescription());

        /*
         * 1. Keyword analysis
         */
        if (jobSpecific) {

            calculateJobSpecificKeywords(
                    input,
                    resumeText,
                    result
            );

        } else {

            calculateGeneralKeywords(
                    resumeText,
                    result
            );
        }

        /*
         * 2. Skills analysis
         */
        int skillsScore =
                calculateSkillsScore(input);

        result.setSkillsScore(skillsScore);

        /*
         * 3. Experience analysis
         */
        int experienceScore =
                calculateExperienceScore(input);

        result.setExperienceScore(
                experienceScore
        );

        /*
         * 4. Education analysis
         */
        int educationScore =
                calculateEducationScore(input);

        result.setEducationScore(
                educationScore
        );

        /*
         * 5. Formatting/completeness analysis
         */
        int formattingScore =
                calculateFormattingScore(input);

        result.setFormattingScore(
                formattingScore
        );

        /*
         * 6. Overall score
         */
        int overallScore;

        if (jobSpecific) {

            overallScore =
                    weightedScore(
                            result.getKeywordScore(),
                            skillsScore,
                            experienceScore,
                            educationScore,
                            formattingScore
                    );

        } else {

            /*
             * General analysis does not have a target job,
             * therefore keyword matching receives lower weight.
             */
            overallScore =
                    weightedGeneralScore(
                            result.getKeywordScore(),
                            skillsScore,
                            experienceScore,
                            educationScore,
                            formattingScore
                    );
        }

        result.setAtsScore(
                clamp(overallScore)
        );

        /*
         * 7. Generate findings.
         */
        generateStrengths(
                input,
                result
        );

        generateWeaknesses(
                input,
                result
        );

        generateSuggestions(
                input,
                result
        );

        return result;
    }

    private void validateInput(
            AtsEngineInput input
    ) {

        if (input == null) {

            throw new IllegalArgumentException(
                    "ATS engine input must not be null."
            );
        }
    }

    private String buildResumeText(
            AtsEngineInput input
    ) {

        List<String> sections =
                new ArrayList<>();

        addIfPresent(
                sections,
                input.getResumeTitle()
        );

        addIfPresent(
                sections,
                input.getHeadline()
        );

        addIfPresent(
                sections,
                input.getProfessionalSummary()
        );

        addAllIfPresent(
                sections,
                input.getSkills()
        );

        addAllIfPresent(
                sections,
                input.getExperiences()
        );

        addAllIfPresent(
                sections,
                input.getEducation()
        );

        addAllIfPresent(
                sections,
                input.getProjects()
        );

        addAllIfPresent(
                sections,
                input.getCertifications()
        );

        addAllIfPresent(
                sections,
                input.getLanguages()
        );

        return String.join(
                " ",
                sections
        );
    }

    private void calculateJobSpecificKeywords(
            AtsEngineInput input,
            String resumeText,
            AtsEngineResult result
    ) {

        Set<String> jobKeywords =
                extractKeywords(
                        input.getJobDescription()
                );

        String normalizedResume =
                normalizeText(resumeText);

        List<String> matched =
                new ArrayList<>();

        List<String> missing =
                new ArrayList<>();

        for (String keyword : jobKeywords) {

            if (containsKeyword(
                    normalizedResume,
                    keyword
            )) {

                matched.add(keyword);

            } else {

                missing.add(keyword);
            }
        }

        result.setMatchedKeywords(
                matched
        );

        result.setMissingKeywords(
                missing
        );

        if (jobKeywords.isEmpty()) {

            result.setKeywordScore(0);

            return;
        }

        int score =
                (int) Math.round(
                        matched.size()
                                * 100.0
                                / jobKeywords.size()
                );

        result.setKeywordScore(
                clamp(score)
        );
    }

    private void calculateGeneralKeywords(
            String resumeText,
            AtsEngineResult result
    ) {

        Set<String> detected =
                extractTechnicalKeywords(
                        resumeText
                );

        result.setMatchedKeywords(
                new ArrayList<>(detected)
        );

        result.setMissingKeywords(
                new ArrayList<>()
        );

        /*
         * A general analysis cannot honestly claim that
         * a resume is missing job-specific keywords.
         *
         * Instead, score based on technical keyword presence.
         */
        int score;

        if (detected.isEmpty()) {

            score = 0;

        } else if (detected.size() >= 10) {

            score = 100;

        } else {

            score =
                    detected.size() * 10;
        }

        result.setKeywordScore(
                clamp(score)
        );
    }

    private int calculateSkillsScore(
            AtsEngineInput input
    ) {

        if (isEmpty(input.getSkills())) {
            return 0;
        }

        int score = 100;

        if (input.getSkills().size() < 3) {
            score -= 25;
        }

        if (input.getSkills().size() > 30) {
            score -= 15;
        }

        return clamp(score);
    }

    private int calculateExperienceScore(
            AtsEngineInput input
    ) {

        if (isEmpty(input.getExperiences())) {
            return 25;
        }

        if (input.getExperiences().size() >= 3) {
            return 100;
        }

        if (input.getExperiences().size() == 2) {
            return 85;
        }

        return 70;
    }

    private int calculateEducationScore(
            AtsEngineInput input
    ) {

        if (isEmpty(input.getEducation())) {
            return 20;
        }

        return 100;
    }

    private int calculateFormattingScore(
            AtsEngineInput input
    ) {

        int score = 0;

        if (hasText(input.getHeadline())) {
            score += 15;
        }

        if (hasText(
                input.getProfessionalSummary()
        )) {
            score += 20;
        }

        if (!isEmpty(input.getSkills())) {
            score += 15;
        }

        if (!isEmpty(input.getExperiences())) {
            score += 15;
        }

        if (!isEmpty(input.getEducation())) {
            score += 15;
        }

        if (!isEmpty(input.getProjects())) {
            score += 10;
        }

        if (!isEmpty(input.getCertifications())) {
            score += 5;
        }

        if (!isEmpty(input.getLanguages())) {
            score += 5;
        }

        return clamp(score);
    }

    private int weightedScore(
            int keywordScore,
            int skillsScore,
            int experienceScore,
            int educationScore,
            int formattingScore
    ) {

        return (int) Math.round(
                keywordScore * 0.35
                        + skillsScore * 0.20
                        + experienceScore * 0.15
                        + educationScore * 0.10
                        + formattingScore * 0.20
        );
    }

    private int weightedGeneralScore(
            int keywordScore,
            int skillsScore,
            int experienceScore,
            int educationScore,
            int formattingScore
    ) {

        return (int) Math.round(
                keywordScore * 0.15
                        + skillsScore * 0.25
                        + experienceScore * 0.20
                        + educationScore * 0.15
                        + formattingScore * 0.25
        );
    }

    private Set<String> extractKeywords(
            String text
    ) {

        if (!hasText(text)) {
            return new LinkedHashSet<>();
        }

        String normalized =
                normalizeText(text);

        Set<String> keywords =
                new LinkedHashSet<>();

        /*
         * First detect known multi-word technical terms.
         */
        for (String technicalKeyword :
                TECHNICAL_KEYWORDS) {

            if (normalized.contains(
                    technicalKeyword
            )) {

                keywords.add(
                        technicalKeyword
                );
            }
        }

        /*
         * Then detect meaningful individual words.
         */
        String[] tokens =
                normalized.split("\\s+");

        for (String token : tokens) {

            if (token.length() < 3) {
                continue;
            }

            if (STOP_WORDS.contains(token)) {
                continue;
            }

            if (isLikelyKeyword(token)) {
                keywords.add(token);
            }
        }

        return keywords;
    }

    private Set<String> extractTechnicalKeywords(
            String text
    ) {

        if (!hasText(text)) {
            return new LinkedHashSet<>();
        }

        String normalized =
                normalizeText(text);

        return TECHNICAL_KEYWORDS
                .stream()
                .filter(
                        keyword ->
                                normalized.contains(
                                        keyword
                                )
                )
                .collect(
                        Collectors.toCollection(
                                LinkedHashSet::new
                        )
                );
    }

    private boolean isLikelyKeyword(
            String token
    ) {

        if (token.length() < 3) {
            return false;
        }

        if (STOP_WORDS.contains(token)) {
            return false;
        }

        return true;
    }

    private boolean containsKeyword(
            String normalizedResume,
            String keyword
    ) {

        if (keyword.contains(" ")) {

            return normalizedResume.contains(
                    keyword
            );
        }

        return Arrays
                .stream(
                        normalizedResume.split("\\s+")
                )
                .anyMatch(
                        keyword::equals
                );
    }

    private String normalizeText(
            String text
    ) {

        if (!hasText(text)) {
            return "";
        }

        String normalized =
                text
                        .toLowerCase(Locale.ROOT)
                        .replace("&", " and ");

        normalized =
                NON_ALPHANUMERIC
                        .matcher(normalized)
                        .replaceAll(" ");

        return normalized
                .replaceAll("\\s+", " ")
                .trim();
    }

    private void generateStrengths(
            AtsEngineInput input,
            AtsEngineResult result
    ) {

        if (result.getKeywordScore() >= 70) {

            result.getStrengths().add(
                    "Strong keyword alignment with the target role."
            );
        }

        if (result.getSkillsScore() >= 80) {

            result.getStrengths().add(
                    "Good technical skills coverage."
            );
        }

        if (result.getExperienceScore() >= 80) {

            result.getStrengths().add(
                    "Strong experience section coverage."
            );
        }

        if (result.getEducationScore() >= 80) {

            result.getStrengths().add(
                    "Education information is clearly provided."
            );
        }

        if (result.getFormattingScore() >= 80) {

            result.getStrengths().add(
                    "Resume contains the major ATS-readable sections."
            );
        }

        if (result.getStrengths().isEmpty()) {

            result.getStrengths().add(
                    "Resume contains foundational career information."
            );
        }
    }

    private void generateWeaknesses(
            AtsEngineInput input,
            AtsEngineResult result
    ) {

        if (result.getKeywordScore() < 50) {

            result.getWeaknesses().add(
                    "Low keyword alignment with the target role."
            );
        }

        if (result.getSkillsScore() < 60) {

            result.getWeaknesses().add(
                    "Skills section needs stronger coverage."
            );
        }

        if (result.getExperienceScore() < 60) {

            result.getWeaknesses().add(
                    "Experience section has limited coverage."
            );
        }

        if (result.getEducationScore() < 60) {

            result.getWeaknesses().add(
                    "Education information is incomplete or missing."
            );
        }

        if (result.getFormattingScore() < 70) {

            result.getWeaknesses().add(
                    "Several important resume sections are missing."
            );
        }
    }

    private void generateSuggestions(
            AtsEngineInput input,
            AtsEngineResult result
    ) {

        if (!result.getMissingKeywords().isEmpty()) {

            result.getSuggestions().add(
                    "Consider adding relevant missing keywords naturally "
                            + "to your skills, experience, or project descriptions."
            );
        }

        if (result.getSkillsScore() < 70) {

            result.getSuggestions().add(
                    "Expand the skills section with relevant technical "
                            + "skills supported by your actual experience."
            );
        }

        if (result.getExperienceScore() < 70) {

            result.getSuggestions().add(
                    "Add measurable achievements and responsibilities "
                            + "to strengthen the experience section."
            );
        }

        if (result.getEducationScore() < 70) {

            result.getSuggestions().add(
                    "Add complete education details relevant to the role."
            );
        }

        if (!hasText(
                input.getProfessionalSummary()
        )) {

            result.getSuggestions().add(
                    "Add a concise professional summary targeted "
                            + "toward the desired role."
            );
        }

        if (result.getSuggestions().isEmpty()) {

            result.getSuggestions().add(
                    "Continue tailoring the resume to each target role "
                            + "while keeping all information truthful."
            );
        }
    }

    private int clamp(int value) {

        return Math.max(
                0,
                Math.min(100, value)
        );
    }

    private boolean hasText(
            String value
    ) {

        return value != null
                && !value.trim().isEmpty();
    }

    private boolean isEmpty(
            List<?> values
    ) {

        return values == null
                || values.isEmpty();
    }

    private void addIfPresent(
            List<String> target,
            String value
    ) {

        if (hasText(value)) {
            target.add(value);
        }
    }

    private void addAllIfPresent(
            List<String> target,
            List<String> values
    ) {

        if (values == null) {
            return;
        }

        values.stream()
                .filter(this::hasText)
                .forEach(target::add);
    }
}