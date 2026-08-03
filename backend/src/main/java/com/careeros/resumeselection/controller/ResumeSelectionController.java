package com.careeros.resumeselection.controller;

import com.careeros.resumeselection.dto.ResumeSelectionRequest;
import com.careeros.resumeselection.dto.ResumeSelectionResponse;
import com.careeros.resumeselection.service.ResumeSelectionService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/resumes/{resumeId}/selections")
public class ResumeSelectionController {

    private final ResumeSelectionService resumeSelectionService;

    public ResumeSelectionController(
            ResumeSelectionService resumeSelectionService
    ) {
        this.resumeSelectionService = resumeSelectionService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResumeSelectionResponse saveSelections(
            @PathVariable Long resumeId,
            @RequestBody ResumeSelectionRequest request
    ) {
        return resumeSelectionService.saveSelections(
                resumeId,
                request
        );
    }

    @GetMapping
    public ResumeSelectionResponse getSelections(
            @PathVariable Long resumeId
    ) {
        return resumeSelectionService.getSelections(resumeId);
    }
}