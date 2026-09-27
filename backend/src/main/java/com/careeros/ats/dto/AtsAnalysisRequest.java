package com.careeros.ats.dto;

import com.careeros.ats.entity.AtsAnalysisType;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AtsAnalysisRequest {

    @NotNull
    private AtsAnalysisType analysisType;

    private String jobTitle;

    private String jobDescription;
}