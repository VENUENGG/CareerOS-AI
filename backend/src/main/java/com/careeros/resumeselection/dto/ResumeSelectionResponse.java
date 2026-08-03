package com.careeros.resumeselection.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Set;

@Getter
@Setter
public class ResumeSelectionResponse {

    private Long id;

    private Long resumeId;

    private Set<Long> skillIds;

    private Set<Long> projectIds;

    private Set<Long> experienceIds;

    private Set<Long> certificationIds;

    private Set<Long> languageIds;
}