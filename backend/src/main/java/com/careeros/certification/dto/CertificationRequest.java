package com.careeros.certification.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class CertificationRequest {

    @NotBlank(message = "Certification name is required.")
    private String certificationName;

    @NotBlank(message = "Issuing organization is required.")
    private String issuingOrganization;

    @NotNull(message = "Issue date is required.")
    private LocalDate issueDate;

    private LocalDate expiryDate;

    private String credentialId;

    private String credentialUrl;
}