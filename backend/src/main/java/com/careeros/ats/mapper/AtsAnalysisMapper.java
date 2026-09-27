package com.careeros.ats.mapper;

import com.careeros.ats.dto.AtsAnalysisResponse;
import com.careeros.ats.entity.AtsAnalysis;

import java.util.ArrayList;

public final class AtsAnalysisMapper {

    private AtsAnalysisMapper() {
    }

    public static AtsAnalysisResponse toResponse(
            AtsAnalysis analysis
    ) {

        if (analysis == null) {
            throw new IllegalArgumentException(
                    "ATS analysis must not be null."
            );
        }

        AtsAnalysisResponse response =
                new AtsAnalysisResponse();

        response.setId(analysis.getId());

        if (analysis.getResume() != null) {
            response.setResumeId(
                    analysis.getResume().getId()
            );
        }

        response.setAnalysisType(
                analysis.getAnalysisType()
        );

        response.setAtsScore(
                analysis.getAtsScore()
        );

        response.setKeywordScore(
                analysis.getKeywordScore()
        );

        response.setSkillsScore(
                analysis.getSkillsScore()
        );

        response.setExperienceScore(
                analysis.getExperienceScore()
        );

        response.setEducationScore(
                analysis.getEducationScore()
        );

        response.setFormattingScore(
                analysis.getFormattingScore()
        );

        response.setJobTitle(
                analysis.getJobTitle()
        );

        response.setJobDescription(
                analysis.getJobDescription()
        );

        response.setMatchedKeywords(
                analysis.getMatchedKeywords() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(
                        analysis.getMatchedKeywords()
                )
        );

        response.setMissingKeywords(
                analysis.getMissingKeywords() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(
                        analysis.getMissingKeywords()
                )
        );

        response.setStrengths(
                analysis.getStrengths() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(
                        analysis.getStrengths()
                )
        );

        response.setWeaknesses(
                analysis.getWeaknesses() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(
                        analysis.getWeaknesses()
                )
        );

        response.setSuggestions(
                analysis.getSuggestions() == null
                        ? new ArrayList<>()
                        : new ArrayList<>(
                        analysis.getSuggestions()
                )
        );

        response.setCreatedAt(
                analysis.getCreatedAt()
        );

        response.setUpdatedAt(
                analysis.getUpdatedAt()
        );

        return response;
    }
}