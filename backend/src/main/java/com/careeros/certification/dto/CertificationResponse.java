package com.careeros.certification.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class CertificationResponse {

    private Long id;

    private String certificationName;

    private String issuingOrganization;

    private LocalDate issueDate;

    private LocalDate expiryDate;

    private String credentialId;

    private String credentialUrl;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}