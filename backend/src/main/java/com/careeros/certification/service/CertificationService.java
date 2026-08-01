package com.careeros.certification.service;

import com.careeros.certification.dto.CertificationRequest;
import com.careeros.certification.dto.CertificationResponse;

import java.util.List;

public interface CertificationService {

    CertificationResponse createCertification(
            CertificationRequest request
    );

    List<CertificationResponse> getMyCertifications();

    CertificationResponse getCertificationById(Long id);

    CertificationResponse updateCertification(
            Long id,
            CertificationRequest request
    );

    void deleteCertification(Long id);
}