package com.careeros.resumeselection.mapper;

import com.careeros.resumeselection.dto.ResumeSelectionRequest;
import com.careeros.resumeselection.dto.ResumeSelectionResponse;
import com.careeros.resumeselection.entity.ResumeSelection;

import java.util.HashSet;

public class ResumeSelectionMapper {

    private ResumeSelectionMapper() {
    }

    public static void mapRequestToEntity(
            ResumeSelectionRequest request,
            ResumeSelection selection
    ) {

        selection.setSkillIds(
                request.getSkillIds() == null
                        ? new HashSet<>()
                        : new HashSet<>(request.getSkillIds())
        );

        selection.setProjectIds(
                request.getProjectIds() == null
                        ? new HashSet<>()
                        : new HashSet<>(request.getProjectIds())
        );

        selection.setExperienceIds(
                request.getExperienceIds() == null
                        ? new HashSet<>()
                        : new HashSet<>(request.getExperienceIds())
        );

        selection.setCertificationIds(
                request.getCertificationIds() == null
                        ? new HashSet<>()
                        : new HashSet<>(request.getCertificationIds())
        );

        selection.setLanguageIds(
                request.getLanguageIds() == null
                        ? new HashSet<>()
                        : new HashSet<>(request.getLanguageIds())
        );
    }

    public static ResumeSelectionResponse mapEntityToResponse(
            ResumeSelection selection
    ) {

        ResumeSelectionResponse response = new ResumeSelectionResponse();

        response.setId(selection.getId());
        response.setResumeId(selection.getResume().getId());
        response.setSkillIds(new HashSet<>(selection.getSkillIds()));
        response.setProjectIds(new HashSet<>(selection.getProjectIds()));
        response.setExperienceIds(new HashSet<>(selection.getExperienceIds()));
        response.setCertificationIds(new HashSet<>(selection.getCertificationIds()));
        response.setLanguageIds(new HashSet<>(selection.getLanguageIds()));

        return response;
    }
}