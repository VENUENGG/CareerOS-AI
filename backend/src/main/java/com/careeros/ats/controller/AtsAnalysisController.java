package com.careeros.ats.controller;

import com.careeros.ats.dto.AtsAnalysisRequest;
import com.careeros.ats.dto.AtsAnalysisResponse;
import com.careeros.ats.service.AtsAnalysisService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/resumes/{resumeId}/ats")
public class AtsAnalysisController {

    private final AtsAnalysisService atsAnalysisService;

    public AtsAnalysisController(
            AtsAnalysisService atsAnalysisService
    ) {
        this.atsAnalysisService = atsAnalysisService;
    }

    /*
     * Run a new ATS analysis.
     *
     * POST
     * /api/v1/resumes/{resumeId}/ats/analyze
     */
    @PostMapping("/analyze")
    public ResponseEntity<AtsAnalysisResponse> analyzeResume(
            @PathVariable Long resumeId,
            @Valid @RequestBody AtsAnalysisRequest request
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        atsAnalysisService.analyzeResume(
                                resumeId,
                                request
                        )
                );
    }

    /*
     * Get the most recent ATS analysis.
     *
     * GET
     * /api/v1/resumes/{resumeId}/ats/latest
     */
    @GetMapping("/latest")
    public ResponseEntity<AtsAnalysisResponse> getLatestAnalysis(
            @PathVariable Long resumeId
    ) {

        return ResponseEntity.ok(
                atsAnalysisService.getLatestAnalysis(
                        resumeId
                )
        );
    }

    /*
     * Get all previous analyses for this resume.
     *
     * GET
     * /api/v1/resumes/{resumeId}/ats/history
     */
    @GetMapping("/history")
    public ResponseEntity<List<AtsAnalysisResponse>> getAnalysisHistory(
            @PathVariable Long resumeId
    ) {

        return ResponseEntity.ok(
                atsAnalysisService.getAnalysisHistory(
                        resumeId
                )
        );
    }
}