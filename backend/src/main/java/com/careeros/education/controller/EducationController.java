package com.careeros.education.controller;

import com.careeros.education.dto.EducationRequest;
import com.careeros.education.dto.EducationResponse;
import com.careeros.education.service.EducationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/education")
public class EducationController {

    private final EducationService educationService;

    public EducationController(EducationService educationService) {
        this.educationService = educationService;
    }

    @PostMapping
    public ResponseEntity<EducationResponse> createEducation(
            @Valid @RequestBody EducationRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(educationService.createEducation(request));
    }

    @GetMapping
    public ResponseEntity<List<EducationResponse>> getMyEducations() {
        return ResponseEntity.ok(
                educationService.getMyEducations()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<EducationResponse> getEducationById(
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(
                educationService.getEducationById(id)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<EducationResponse> updateEducation(
            @PathVariable Long id,
            @Valid @RequestBody EducationRequest request
    ) {
        return ResponseEntity.ok(
                educationService.updateEducation(id, request)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEducation(
            @PathVariable Long id
    ) {
        educationService.deleteEducation(id);

        return ResponseEntity.noContent().build();
    }
}