package com.careeros.ai.engine;

import com.careeros.ai.dto.CareerCoachResponse;
import com.careeros.experience.entity.Experience;
import com.careeros.skill.entity.Skill;
import com.careeros.user.entity.UserProfile;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Component
public class CareerCoachOfflineEngine {

    public CareerCoachResponse generateOfflineCoach(
            String goal,
            UserProfile profile,
            List<Skill> skills,
            List<Experience> experiences
    ) {

        String normalizedGoal =
                goal == null
                        ? ""
                        : goal.trim().toLowerCase(Locale.ROOT);

        List<String> skillNames =
                skills == null
                        ? List.of()
                        : skills.stream()
                        .map(Skill::getSkillName)
                        .filter(name ->
                                name != null && !name.isBlank()
                        )
                        .map(String::trim)
                        .distinct()
                        .toList();

        List<Experience> safeExperiences =
                experiences == null
                        ? List.of()
                        : experiences;

        String targetTrack =
                detectCareerTrack(
                        normalizedGoal,
                        skillNames
                );

        CareerCoachResponse response =
                new CareerCoachResponse();

        response.setSource("OFFLINE");

        response.setCareerAssessment(
                buildCareerAssessment(
                        profile,
                        skillNames,
                        safeExperiences,
                        targetTrack
                )
        );

        response.setRecommendedRoles(
                getRecommendedRoles(targetTrack)
        );

        List<String> skillGaps =
                getSkillGaps(
                        targetTrack,
                        skillNames
                );

        response.setSkillGaps(skillGaps);

        response.setPrioritySkills(
                getPrioritySkills(skillGaps)
        );

        response.setRoadmap(
                buildRoadmap(
                        targetTrack,
                        skillNames,
                        skillGaps
                )
        );

        response.setNextActions(
                buildNextActions(
                        targetTrack,
                        skillNames,
                        skillGaps
                )
        );

        return response;
    }

    private String detectCareerTrack(
            String goal,
            List<String> skills
    ) {

        if (containsAny(
                goal,
                "java",
                "spring boot",
                "backend",
                "back-end"
        )) {
            return "JAVA_BACKEND";
        }

        if (containsAny(
                goal,
                "devops",
                "cloud",
                "aws",
                "kubernetes"
        )) {
            return "DEVOPS_CLOUD";
        }

        if (containsAny(
                goal,
                "data scientist",
                "data science"
        )) {
            return "DATA_SCIENCE";
        }

        if (containsAny(
                goal,
                "machine learning",
                "machine-learning",
                "ml",
                "ai engineer",
                "artificial intelligence"
        )) {
            return "AI_ML";
        }

        if (containsAny(
                goal,
                "cybersecurity",
                "cyber security",
                "security engineer"
        )) {
            return "CYBERSECURITY";
        }

        if (containsAny(
                goal,
                "frontend",
                "front-end",
                "react",
                "angular"
        )) {
            return "FRONTEND";
        }

        if (containsAny(
                goal,
                "full stack",
                "full-stack"
        )) {
            return "FULL_STACK";
        }

        if (containsAny(
                goal,
                "mobile",
                "android",
                "flutter",
                "ios"
        )) {
            return "MOBILE";
        }

        if (containsAny(
                goal,
                "qa",
                "quality assurance",
                "automation testing",
                "test automation"
        )) {
            return "QA_AUTOMATION";
        }

        String skillsText =
                String.join(
                        " ",
                        skills
                ).toLowerCase(Locale.ROOT);

        if (containsAny(
                skillsText,
                "java",
                "spring"
        )) {
            return "JAVA_BACKEND";
        }

        return "GENERAL_SOFTWARE";
    }

    private String buildCareerAssessment(
            UserProfile profile,
            List<String> skills,
            List<Experience> experiences,
            String track
    ) {

        String currentTitle =
                profile != null
                        ? profile.getCurrentJobTitle()
                        : null;

        int experienceCount =
                experiences.size();

        if (!hasText(currentTitle)) {
            currentTitle = "No current job title provided";
        }

        return "Offline CareerOS assessment: "
                + "current role = "
                + currentTitle
                + ", recorded experiences = "
                + experienceCount
                + ", skills = "
                + skills.size()
                + ". Target track = "
                + formatTrack(track)
                + ".";
    }

    private List<String> getRecommendedRoles(
            String track
    ) {

        return switch (track) {

            case "JAVA_BACKEND" ->
                    List.of(
                            "Java Backend Developer",
                            "Backend Developer",
                            "Software Engineer"
                    );

            case "DEVOPS_CLOUD" ->
                    List.of(
                            "DevOps Engineer",
                            "Cloud Engineer",
                            "Site Reliability Engineer"
                    );

            case "DATA_SCIENCE" ->
                    List.of(
                            "Data Scientist",
                            "Data Analyst",
                            "Machine Learning Analyst"
                    );

            case "AI_ML" ->
                    List.of(
                            "Machine Learning Engineer",
                            "AI Engineer",
                            "Applied AI Engineer"
                    );

            case "CYBERSECURITY" ->
                    List.of(
                            "Cybersecurity Engineer",
                            "Security Analyst",
                            "Application Security Engineer"
                    );

            case "FRONTEND" ->
                    List.of(
                            "Frontend Developer",
                            "UI Engineer",
                            "Web Developer"
                    );

            case "FULL_STACK" ->
                    List.of(
                            "Full Stack Developer",
                            "Software Engineer",
                            "Web Application Developer"
                    );

            case "MOBILE" ->
                    List.of(
                            "Mobile Developer",
                            "Android Developer",
                            "Flutter Developer"
                    );

            case "QA_AUTOMATION" ->
                    List.of(
                            "QA Engineer",
                            "Automation Engineer",
                            "Software Test Engineer"
                    );

            default ->
                    List.of(
                            "Software Engineer",
                            "Backend Developer",
                            "Full Stack Developer"
                    );
        };
    }

    private List<String> getSkillGaps(
            String track,
            List<String> existingSkills
    ) {

        List<String> requiredSkills =
                new ArrayList<>();

        switch (track) {

            case "JAVA_BACKEND" -> requiredSkills.addAll(
                    List.of(
                            "REST APIs",
                            "Database Design",
                            "Microservices",
                            "Docker",
                            "AWS",
                            "Testing"
                    )
            );

            case "DEVOPS_CLOUD" -> requiredSkills.addAll(
                    List.of(
                            "Linux",
                            "Docker",
                            "Kubernetes",
                            "AWS",
                            "CI/CD",
                            "Terraform"
                    )
            );

            case "DATA_SCIENCE" -> requiredSkills.addAll(
                    List.of(
                            "Python",
                            "SQL",
                            "Statistics",
                            "Pandas",
                            "Machine Learning",
                            "Data Visualization"
                    )
            );

            case "AI_ML" -> requiredSkills.addAll(
                    List.of(
                            "Python",
                            "Machine Learning",
                            "Deep Learning",
                            "Model Deployment",
                            "MLOps",
                            "Data Engineering"
                    )
            );

            case "CYBERSECURITY" -> requiredSkills.addAll(
                    List.of(
                            "Networking",
                            "Linux",
                            "Application Security",
                            "OWASP",
                            "Threat Modeling",
                            "Security Testing"
                    )
            );

            case "FRONTEND" -> requiredSkills.addAll(
                    List.of(
                            "JavaScript",
                            "TypeScript",
                            "React",
                            "Testing",
                            "Accessibility",
                            "Performance Optimization"
                    )
            );

            case "FULL_STACK" -> requiredSkills.addAll(
                    List.of(
                            "Frontend Framework",
                            "REST APIs",
                            "Database Design",
                            "Authentication",
                            "Testing",
                            "Deployment"
                    )
            );

            case "MOBILE" -> requiredSkills.addAll(
                    List.of(
                            "Mobile UI",
                            "State Management",
                            "REST APIs",
                            "Local Storage",
                            "Testing",
                            "App Deployment"
                    )
            );

            case "QA_AUTOMATION" -> requiredSkills.addAll(
                    List.of(
                            "Test Automation",
                            "Selenium",
                            "API Testing",
                            "CI/CD",
                            "Test Design",
                            "Performance Testing"
                    )
            );

            default -> requiredSkills.addAll(
                    List.of(
                            "Data Structures",
                            "Algorithms",
                            "Git",
                            "Testing",
                            "Cloud Fundamentals",
                            "System Design"
                    )
            );
        }

        List<String> normalizedExisting =
                existingSkills.stream()
                        .filter(this::hasText)
                        .map(skill ->
                                skill.toLowerCase(
                                        Locale.ROOT
                                )
                        )
                        .toList();

        return requiredSkills.stream()
                .filter(required ->
                        normalizedExisting.stream()
                                .noneMatch(existing ->
                                        existing.contains(
                                                required.toLowerCase(
                                                        Locale.ROOT
                                                )
                                        )
                                )
                )
                .toList();
    }

    private List<String> getPrioritySkills(
            List<String> skillGaps
    ) {

        return skillGaps.stream()
                .limit(3)
                .toList();
    }

    private List<CareerCoachResponse.CareerRoadmapPhase>
    buildRoadmap(
            String track,
            List<String> existingSkills,
            List<String> skillGaps
    ) {

        List<CareerCoachResponse.CareerRoadmapPhase>
                phases =
                new ArrayList<>();

        /*
         * When all major skills are already present,
         * the roadmap should still provide useful
         * actions instead of empty phases.
         */
        if (skillGaps.isEmpty()) {

            phases.add(
                    createPhase(
                            1,
                            "Strengthen Foundations",
                            "2-3 weeks",
                            List.of(
                                    "Advanced problem solving",
                                    "Testing",
                                    "Code quality"
                            )
                    )
            );

            phases.add(
                    createPhase(
                            2,
                            "Build a Production Project",
                            "4-6 weeks",
                            List.of(
                                    "Architecture",
                                    "Deployment",
                                    "Monitoring"
                            )
                    )
            );

            phases.add(
                    createPhase(
                            3,
                            "Career Readiness",
                            "2-4 weeks",
                            List.of(
                                    "Resume optimization",
                                    "Interview preparation",
                                    "Applications"
                            )
                    )
            );

            return phases;
        }

        /*
         * Phase 1: foundational gaps.
         */
        List<String> phase1 =
                takeRange(
                        skillGaps,
                        0,
                        Math.min(2, skillGaps.size())
                );

        /*
         * Phase 2: implementation/production gaps.
         */
        List<String> phase2 =
                takeRange(
                        skillGaps,
                        Math.min(2, skillGaps.size()),
                        Math.min(4, skillGaps.size())
                );

        /*
         * Whatever remains becomes Phase 3.
         */
        List<String> phase3 =
                takeRange(
                        skillGaps,
                        Math.min(4, skillGaps.size()),
                        skillGaps.size()
                );

        if (phase1.isEmpty()) {
            phase1 = List.of(
                    "Fundamentals",
                    "Problem Solving"
            );
        }

        if (phase2.isEmpty()) {
            phase2 = List.of(
                    "Practical Project",
                    "Testing"
            );
        }

        if (phase3.isEmpty()) {
            phase3 = List.of(
                    "Production Deployment",
                    "Interview Preparation",
                    "Resume Optimization"
            );
        }

        phases.add(
                createPhase(
                        1,
                        "Foundation",
                        "3-4 weeks",
                        phase1
                )
        );

        phases.add(
                createPhase(
                        2,
                        "Practical Projects",
                        "4-6 weeks",
                        phase2
                )
        );

        phases.add(
                createPhase(
                        3,
                        "Production Readiness",
                        "4-6 weeks",
                        phase3
                )
        );

        return phases;
    }

    private CareerCoachResponse.CareerRoadmapPhase
    createPhase(
            int phaseNumber,
            String title,
            String duration,
            List<String> skills
    ) {

        CareerCoachResponse.CareerRoadmapPhase phase =
                new CareerCoachResponse.CareerRoadmapPhase();

        phase.setPhase(phaseNumber);
        phase.setTitle(title);
        phase.setDuration(duration);
        phase.setSkills(
                new ArrayList<>(skills)
        );

        return phase;
    }

    private List<String> buildNextActions(
            String track,
            List<String> existingSkills,
            List<String> skillGaps
    ) {

        if (skillGaps.isEmpty()) {
            return List.of(
                    "Build a production-grade project for your target role.",
                    "Add measurable outcomes and technical depth to your resume.",
                    "Practice role-specific interview questions.",
                    "Start applying and track interview feedback."
            );
        }

        List<String> actions =
                new ArrayList<>();

        String firstGap =
                skillGaps.get(0);

        actions.add(
                "Start learning: "
                        + firstGap
                        + "."
        );

        if (skillGaps.size() > 1) {

            actions.add(
                    "Build one practical project using "
                            + skillGaps.get(1)
                            + "."
            );
        }

        if (skillGaps.size() > 2) {

            actions.add(
                    "Add "
                            + skillGaps.get(2)
                            + " to your project stack."
            );
        }

        actions.add(
                "Document measurable project outcomes "
                        + "for your resume."
        );

        actions.add(
                "Practice interview questions for "
                        + formatTrack(track)
                        + " roles."
        );

        return actions;
    }

    private List<String> takeRange(
            List<String> values,
            int fromIndex,
            int toIndex
    ) {

        if (values.isEmpty() || fromIndex >= values.size()) {
            return new ArrayList<>();
        }

        int safeFrom =
                Math.max(0, fromIndex);

        int safeTo =
                Math.min(
                        values.size(),
                        Math.max(
                                safeFrom,
                                toIndex
                        )
                );

        return new ArrayList<>(
                values.subList(
                        safeFrom,
                        safeTo
                )
        );
    }

    private boolean containsAny(
            String value,
            String... terms
    ) {

        if (value == null) {
            return false;
        }

        String normalized =
                value.toLowerCase(
                        Locale.ROOT
                );

        for (String term : terms) {

            if (normalized.contains(
                    term.toLowerCase(
                            Locale.ROOT
                    )
            )) {
                return true;
            }
        }

        return false;
    }

    private boolean hasText(
            String value
    ) {

        return value != null
                && !value.trim().isEmpty();
    }

    private String formatTrack(
            String track
    ) {

        return track.replace(
                '_',
                ' '
        );
    }
}