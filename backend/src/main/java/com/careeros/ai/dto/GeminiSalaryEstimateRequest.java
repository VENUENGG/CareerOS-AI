package com.careeros.ai.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class GeminiSalaryEstimateRequest {

    private String jobTitle;

    private String location;

    private String industry;

    private Integer experienceYears;

    private List<String> skills;
}