package com.careeros.experience.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class ExperienceResponse {

    private Long id;

    private String companyName;

    private String jobTitle;

    private String employmentType;

    private String location;

    private Boolean currentlyWorking;

    private LocalDate startDate;

    private LocalDate endDate;

    private String description;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}