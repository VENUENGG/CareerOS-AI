package com.careeros.resume.dto;

import com.careeros.resume.enums.TemplateType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResumeRequest {

    private String title;

    private TemplateType templateType;

    private String professionalSummary;

    private Boolean isPublic;
}