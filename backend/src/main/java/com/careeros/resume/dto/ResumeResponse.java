package com.careeros.resume.dto;

import com.careeros.resume.enums.TemplateType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ResumeResponse {

    private Long id;

    private String title;

    private TemplateType templateType;

    private String professionalSummary;

    private Boolean isPublic;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}