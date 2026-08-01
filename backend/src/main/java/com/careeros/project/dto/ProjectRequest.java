package com.careeros.project.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class ProjectRequest {

    @NotBlank(message = "Project name is required.")
    private String projectName;

    private String description;

    @NotBlank(message = "Technologies are required.")
    private String technologies;

    private String githubUrl;

    private String liveUrl;

    @NotNull(message = "Currently working is required.")
    private Boolean currentlyWorking;

    @NotNull(message = "Start date is required.")
    private LocalDate startDate;

    private LocalDate endDate;
}