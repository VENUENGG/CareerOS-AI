package com.careeros.experience.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class ExperienceRequest {

    @NotBlank(message = "Company name is required.")
    private String companyName;

    @NotBlank(message = "Job title is required.")
    private String jobTitle;

    private String employmentType;

    private String location;

    @NotNull(message = "Currently working field is required.")
    private Boolean currentlyWorking;

    @NotNull(message = "Start date is required.")
    private LocalDate startDate;

    private LocalDate endDate;

    private String description;
}