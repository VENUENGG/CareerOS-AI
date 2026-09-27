package com.careeros.ats.dto;

import com.careeros.ats.entity.AtsAnalysisType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class AtsAnalysisResponse {

    private Long id;

    private Long resumeId;

    private AtsAnalysisType analysisType;

    private Integer atsScore;

    private Integer keywordScore;

    private Integer skillsScore;

    private Integer experienceScore;

    private Integer educationScore;

    private Integer formattingScore;

    private String jobTitle;

    private String jobDescription;

    private List<String> matchedKeywords;

    private List<String> missingKeywords;

    private List<String> strengths;

    private List<String> weaknesses;

    private List<String> suggestions;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}