package com.careeros.resume.controller;

import com.careeros.resume.dto.ResumeRequest;
import com.careeros.resume.dto.ResumeResponse;
import com.careeros.resume.service.ResumeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/resumes")
public class ResumeController {

    private final ResumeService resumeService;

    public ResumeController(
            ResumeService resumeService
    ) {
        this.resumeService = resumeService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResumeResponse createResume(
            @Valid @RequestBody ResumeRequest request
    ) {
        return resumeService.createResume(request);
    }

    @GetMapping
    public List<ResumeResponse> getMyResumes() {
        return resumeService.getMyResumes();
    }

    @GetMapping("/{id}")
    public ResumeResponse getResumeById(
            @PathVariable Long id
    ) {
        return resumeService.getResumeById(id);
    }

    @PutMapping("/{id}")
    public ResumeResponse updateResume(
            @PathVariable Long id,
            @Valid @RequestBody ResumeRequest request
    ) {
        return resumeService.updateResume(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteResume(
            @PathVariable Long id
    ) {
        resumeService.deleteResume(id);
    }
}