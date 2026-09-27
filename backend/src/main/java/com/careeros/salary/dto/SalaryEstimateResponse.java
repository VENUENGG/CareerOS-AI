package com.careeros.salary.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Set;

@Getter
@Setter
public class SalaryEstimateResponse {

    private Long id;

    private String jobTitle;

    private String location;

    private String industry;

    private Integer experienceYears;

    private BigDecimal minimumSalary;

    private BigDecimal expectedSalary;

    private BigDecimal maximumSalary;

    private String currency;

    private String marketPosition;

    private Set<String> factors;

    private Set<String> skillNames;

    private String createdAt;
}