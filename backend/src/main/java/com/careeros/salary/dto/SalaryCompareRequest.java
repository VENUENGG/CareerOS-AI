package com.careeros.salary.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class SalaryCompareRequest {

    @NotNull(message = "Current salary is required.")
    @DecimalMin(
            value = "0.0",
            inclusive = false,
            message = "Current salary must be greater than zero."
    )
    private BigDecimal currentSalary;

    @Valid
    @NotNull(message = "Salary estimate details are required.")
    private SalaryEstimateRequest estimate;

    public BigDecimal getCurrentSalary() {
        return currentSalary;
    }

    public void setCurrentSalary(BigDecimal currentSalary) {
        this.currentSalary = currentSalary;
    }

    public SalaryEstimateRequest getEstimate() {
        return estimate;
    }

    public void setEstimate(SalaryEstimateRequest estimate) {
        this.estimate = estimate;
    }
}