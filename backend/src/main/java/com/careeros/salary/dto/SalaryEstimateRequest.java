package com.careeros.salary.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.util.Set;

public class SalaryEstimateRequest {

    @NotBlank(message = "Job title is required.")
    @Size(max = 150, message = "Job title must not exceed 150 characters.")
    private String jobTitle;

    @NotBlank(message = "Location is required.")
    @Size(max = 150, message = "Location must not exceed 150 characters.")
    private String location;

    @NotBlank(message = "Industry is required.")
    @Size(max = 100, message = "Industry must not exceed 100 characters.")
    private String industry;

    @NotNull(message = "Experience years is required.")
    @Min(value = 0, message = "Experience years cannot be negative.")
    @Max(value = 50, message = "Experience years cannot exceed 50.")
    private Integer experienceYears;

    @DecimalMin(value = "0.0", inclusive = false,
            message = "Current salary must be greater than zero.")
    private BigDecimal currentSalary;

    private Set<Long> skillIds;

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public Integer getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(Integer experienceYears) {
        this.experienceYears = experienceYears;
    }

    public BigDecimal getCurrentSalary() {
        return currentSalary;
    }

    public void setCurrentSalary(BigDecimal currentSalary) {
        this.currentSalary = currentSalary;
    }

    public Set<Long> getSkillIds() {
        return skillIds;
    }

    public void setSkillIds(Set<Long> skillIds) {
        this.skillIds = skillIds;
    }
}