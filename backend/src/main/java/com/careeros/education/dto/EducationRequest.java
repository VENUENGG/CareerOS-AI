package com.careeros.education.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public class EducationRequest {

    @NotBlank
    private String institutionName;

    @NotBlank
    private String degree;

    @NotBlank
    private String fieldOfStudy;

    private String grade;

    @NotNull
    private LocalDate startDate;

    private LocalDate endDate;

    @NotNull
    private Boolean currentlyStudying;

    private String description;

    public String getInstitutionName() {
        return institutionName;
    }

    public void setInstitutionName(String institutionName) {
        this.institutionName = institutionName;
    }

    public String getDegree() {
        return degree;
    }

    public void setDegree(String degree) {
        this.degree = degree;
    }

    public String getFieldOfStudy() {
        return fieldOfStudy;
    }

    public void setFieldOfStudy(String fieldOfStudy) {
        this.fieldOfStudy = fieldOfStudy;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public Boolean getCurrentlyStudying() {
        return currentlyStudying;
    }

    public void setCurrentlyStudying(Boolean currentlyStudying) {
        this.currentlyStudying = currentlyStudying;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}