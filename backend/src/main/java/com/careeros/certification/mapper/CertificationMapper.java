package com.careeros.certification.mapper;

import com.careeros.certification.dto.CertificationRequest;
import com.careeros.certification.dto.CertificationResponse;
import com.careeros.certification.entity.Certification;

public class CertificationMapper {

    private CertificationMapper() {
    }

    public static void mapRequestToEntity(
            CertificationRequest request,
            Certification certification
    ) {

        certification.setCertificationName(request.getCertificationName());
        certification.setIssuingOrganization(request.getIssuingOrganization());
        certification.setIssueDate(request.getIssueDate());
        certification.setExpiryDate(request.getExpiryDate());
        certification.setCredentialId(request.getCredentialId());
        certification.setCredentialUrl(request.getCredentialUrl());
    }

    public static CertificationResponse mapEntityToResponse(
            Certification certification
    ) {

        CertificationResponse response = new CertificationResponse();

        response.setId(certification.getId());
        response.setCertificationName(certification.getCertificationName());
        response.setIssuingOrganization(certification.getIssuingOrganization());
        response.setIssueDate(certification.getIssueDate());
        response.setExpiryDate(certification.getExpiryDate());
        response.setCredentialId(certification.getCredentialId());
        response.setCredentialUrl(certification.getCredentialUrl());
        response.setCreatedAt(certification.getCreatedAt());
        response.setUpdatedAt(certification.getUpdatedAt());

        return response;
    }
}