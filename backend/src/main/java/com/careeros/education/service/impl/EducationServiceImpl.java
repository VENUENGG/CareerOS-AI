package com.careeros.education.service.impl;

import com.careeros.exception.EducationNotFoundException;
import com.careeros.education.mapper.EducationMapper;
import com.careeros.education.dto.EducationRequest;
import com.careeros.education.dto.EducationResponse;
import com.careeros.education.entity.Education;
import com.careeros.education.repository.EducationRepository;
import com.careeros.education.service.EducationService;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class EducationServiceImpl implements EducationService {

    private final EducationRepository educationRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public EducationServiceImpl(
            EducationRepository educationRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.educationRepository = educationRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser = authenticatedUserService.getCurrentUser();

        return userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new UserProfileNotFoundException(
                                "User profile not found."
                        )
                );
    }
    @Override
    public EducationResponse createEducation(EducationRequest request) {

        UserProfile userProfile = getCurrentUserProfile();

        Education education = new Education();

        education.setUserProfile(userProfile);

        EducationMapper.mapRequestToEntity(
                request,
                education
        );

        Education savedEducation =
                educationRepository.save(education);

        return EducationMapper.mapEntityToResponse(savedEducation);
    }
    @Override
    @Transactional(readOnly = true)
    public java.util.List<EducationResponse> getMyEducations() {

        UserProfile userProfile = getCurrentUserProfile();

        return educationRepository.findByUserProfile(userProfile)
                .stream()
                .map(EducationMapper::mapEntityToResponse)
                .toList();
    }
    @Override
    @Transactional(readOnly = true)
    public EducationResponse getEducationById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Education education = educationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new EducationNotFoundException(
                                "Education not found."
                        )
                );

        return EducationMapper.mapEntityToResponse(education);
    }


    @Override
    public EducationResponse updateEducation(
            Long id,
            EducationRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Education education = educationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new EducationNotFoundException(
                                "Education not found."
                        )
                );

        EducationMapper.mapRequestToEntity(
                request,
                education
        );

        Education updatedEducation =
                educationRepository.save(education);

        return EducationMapper.mapEntityToResponse(updatedEducation);
    }

    @Override
    public void deleteEducation(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Education education = educationRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new EducationNotFoundException(
                                "Education not found."
                        )
                );

        educationRepository.delete(education);
    }
}