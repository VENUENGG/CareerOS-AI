package com.careeros.ai.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class GeminiSalaryEstimateResponse {

    private BigDecimal minimumSalary;

    private BigDecimal expectedSalary;

    private BigDecimal maximumSalary;

    private String currency;

    private List<String> factors;

    private String provider;
}