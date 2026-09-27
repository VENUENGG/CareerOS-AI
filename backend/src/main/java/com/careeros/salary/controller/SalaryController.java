package com.careeros.salary.controller;

import com.careeros.salary.dto.SalaryCompareRequest;
import com.careeros.salary.dto.SalaryCompareResponse;
import com.careeros.salary.dto.SalaryEstimateRequest;
import com.careeros.salary.dto.SalaryEstimateResponse;
import com.careeros.salary.service.SalaryService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/salary")
public class SalaryController {

    private final SalaryService salaryService;

    public SalaryController(
            SalaryService salaryService
    ) {
        this.salaryService = salaryService;
    }

    @PostMapping("/estimate")
    public ResponseEntity<SalaryEstimateResponse>
    estimateSalary(
            @Valid @RequestBody SalaryEstimateRequest request
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        salaryService.estimateSalary(
                                request
                        )
                );
    }

    @PostMapping("/compare")
    public ResponseEntity<SalaryCompareResponse>
    compareSalary(
            @Valid @RequestBody SalaryCompareRequest request
    ) {

        return ResponseEntity.ok(
                salaryService.compareSalary(
                        request
                )
        );
    }

    @GetMapping("/latest")
    public ResponseEntity<SalaryEstimateResponse>
    getLatestSalaryAnalysis() {

        return ResponseEntity.ok(
                salaryService.getLatestSalaryAnalysis()
        );
    }

    @GetMapping("/history")
    public ResponseEntity<List<SalaryEstimateResponse>>
    getSalaryHistory() {

        return ResponseEntity.ok(
                salaryService.getSalaryHistory()
        );
    }
}