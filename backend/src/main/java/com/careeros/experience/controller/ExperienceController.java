package com.careeros.experience.controller;

import com.careeros.experience.dto.ExperienceRequest;
import com.careeros.experience.dto.ExperienceResponse;
import com.careeros.experience.service.ExperienceService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/experience")
public class ExperienceController {

    private final ExperienceService experienceService;

    public ExperienceController(
            ExperienceService experienceService
    ) {
        this.experienceService = experienceService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ExperienceResponse createExperience(
            @Valid @RequestBody ExperienceRequest request
    ) {
        return experienceService.createExperience(request);
    }

    @GetMapping
    public List<ExperienceResponse> getMyExperiences() {
        return experienceService.getMyExperiences();
    }

    @GetMapping("/{id}")
    public ExperienceResponse getExperienceById(
            @PathVariable Long id
    ) {
        return experienceService.getExperienceById(id);
    }

    @PutMapping("/{id}")
    public ExperienceResponse updateExperience(
            @PathVariable Long id,
            @Valid @RequestBody ExperienceRequest request
    ) {
        return experienceService.updateExperience(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteExperience(
            @PathVariable Long id
    ) {
        experienceService.deleteExperience(id);
    }
}