package com.careeros.salary.service;

import com.careeros.salary.dto.SalaryCompareRequest;
import com.careeros.salary.dto.SalaryCompareResponse;
import com.careeros.salary.dto.SalaryEstimateRequest;
import com.careeros.salary.dto.SalaryEstimateResponse;

import java.util.List;

public interface SalaryService {

    SalaryEstimateResponse estimateSalary(
            SalaryEstimateRequest request
    );

    SalaryCompareResponse compareSalary(
            SalaryCompareRequest request
    );

    SalaryEstimateResponse getLatestSalaryAnalysis();

    List<SalaryEstimateResponse> getSalaryHistory();
}