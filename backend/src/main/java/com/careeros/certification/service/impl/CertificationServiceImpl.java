package com.careeros.certification.service.impl;

import com.careeros.certification.dto.CertificationRequest;
import com.careeros.certification.dto.CertificationResponse;
import com.careeros.certification.entity.Certification;
import com.careeros.certification.mapper.CertificationMapper;
import com.careeros.certification.repository.CertificationRepository;
import com.careeros.certification.service.CertificationService;
import com.careeros.exception.CertificationNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class CertificationServiceImpl implements CertificationService {

    private final CertificationRepository certificationRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public CertificationServiceImpl(
            CertificationRepository certificationRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.certificationRepository = certificationRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser =
                authenticatedUserService.getCurrentUser();

        return userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new UserProfileNotFoundException(
                                "User profile not found."
                        )
                );

    }

    @Override
    public CertificationResponse createCertification(
            CertificationRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Certification certification = new Certification();

        certification.setUserProfile(userProfile);

        CertificationMapper.mapRequestToEntity(
                request,
                certification
        );

        Certification savedCertification =
                certificationRepository.save(certification);

        return CertificationMapper.mapEntityToResponse(savedCertification);
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.List<CertificationResponse> getMyCertifications() {

        UserProfile userProfile = getCurrentUserProfile();

        return certificationRepository.findByUserProfile(userProfile)
                .stream()
                .map(CertificationMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CertificationResponse getCertificationById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Certification certification = certificationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new CertificationNotFoundException(
                                "Certification not found."
                        )
                );

        return CertificationMapper.mapEntityToResponse(certification);
    }

    @Override
    public CertificationResponse updateCertification(
            Long id,
            CertificationRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Certification certification = certificationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new CertificationNotFoundException(
                                "Certification not found."
                        )
                );

        CertificationMapper.mapRequestToEntity(
                request,
                certification
        );

        Certification updatedCertification =
                certificationRepository.save(certification);

        return CertificationMapper.mapEntityToResponse(updatedCertification);
    }

    @Override
    public void deleteCertification(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Certification certification = certificationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new CertificationNotFoundException(
                                "Certification not found."
                        )
                );

        certificationRepository.delete(certification);
    }
}
