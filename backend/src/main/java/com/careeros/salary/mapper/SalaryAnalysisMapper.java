package com.careeros.salary.mapper;

import com.careeros.salary.dto.SalaryEstimateResponse;
import com.careeros.salary.entity.SalaryAnalysis;

import java.util.HashSet;

public final class SalaryAnalysisMapper {

    private SalaryAnalysisMapper() {
    }

    public static SalaryEstimateResponse
    mapToResponse(SalaryAnalysis analysis) {

        SalaryEstimateResponse response =
                new SalaryEstimateResponse();

        response.setId(analysis.getId());
        response.setJobTitle(analysis.getJobTitle());
        response.setLocation(analysis.getLocation());
        response.setIndustry(analysis.getIndustry());
        response.setExperienceYears(
                analysis.getExperienceYears()
        );

        response.setMinimumSalary(
                analysis.getMinimumSalary()
        );

        response.setExpectedSalary(
                analysis.getExpectedSalary()
        );

        response.setMaximumSalary(
                analysis.getMaximumSalary()
        );

        response.setCurrency(
                analysis.getCurrency()
        );

        response.setMarketPosition(
                analysis.getMarketPosition()
        );

        response.setFactors(
                new HashSet<>(analysis.getFactors())
        );

        response.setSkillNames(
                new HashSet<>(analysis.getSkillNames())
        );

        response.setCreatedAt(
                analysis.getCreatedAt() != null
                        ? analysis.getCreatedAt().toString()
                        : null
        );

        return response;
    }
}