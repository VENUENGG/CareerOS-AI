package com.careeros.salary.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class SalaryCompareResponse {

    private BigDecimal currentSalary;

    private BigDecimal expectedSalary;

    private BigDecimal minimumSalary;

    private BigDecimal maximumSalary;

    private BigDecimal differenceFromExpected;

    private BigDecimal percentageDifference;

    private String marketPosition;

    private String message;

    private SalaryEstimateResponse estimate;
}