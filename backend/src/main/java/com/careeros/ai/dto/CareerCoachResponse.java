package com.careeros.ai.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class CareerCoachResponse {

    private String source;

    private String careerAssessment;

    private List<String> recommendedRoles =
            new ArrayList<>();

    private List<String> skillGaps =
            new ArrayList<>();

    private List<String> prioritySkills =
            new ArrayList<>();

    private List<CareerRoadmapPhase> roadmap =
            new ArrayList<>();

    private List<String> nextActions =
            new ArrayList<>();

    @Getter
    @Setter
    public static class CareerRoadmapPhase {

        private Integer phase;

        private String title;

        private String duration;

        private List<String> skills =
                new ArrayList<>();
    }
}