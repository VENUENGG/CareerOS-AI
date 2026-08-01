package com.careeros.project.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class ProjectResponse {

    private Long id;

    private String projectName;

    private String description;

    private String technologies;

    private String githubUrl;

    private String liveUrl;

    private Boolean currentlyWorking;

    private LocalDate startDate;

    private LocalDate endDate;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}