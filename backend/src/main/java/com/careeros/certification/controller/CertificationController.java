package com.careeros.certification.controller;

import com.careeros.certification.dto.CertificationRequest;
import com.careeros.certification.dto.CertificationResponse;
import com.careeros.certification.service.CertificationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/certifications")
public class CertificationController {

    private final CertificationService certificationService;

    public CertificationController(
            CertificationService certificationService
    ) {
        this.certificationService = certificationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CertificationResponse createCertification(
            @Valid @RequestBody CertificationRequest request
    ) {
        return certificationService.createCertification(request);
    }

    @GetMapping
    public List<CertificationResponse> getMyCertifications() {
        return certificationService.getMyCertifications();
    }

    @GetMapping("/{id}")
    public CertificationResponse getCertificationById(
            @PathVariable Long id
    ) {
        return certificationService.getCertificationById(id);
    }

    @PutMapping("/{id}")
    public CertificationResponse updateCertification(
            @PathVariable Long id,
            @Valid @RequestBody CertificationRequest request
    ) {
        return certificationService.updateCertification(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCertification(
            @PathVariable Long id
    ) {
        certificationService.deleteCertification(id);
    }
}