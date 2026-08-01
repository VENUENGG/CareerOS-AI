package com.careeros.experience.service.impl;

import com.careeros.exception.ExperienceNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.experience.dto.ExperienceRequest;
import com.careeros.experience.dto.ExperienceResponse;
import com.careeros.experience.entity.Experience;
import com.careeros.experience.mapper.ExperienceMapper;
import com.careeros.experience.repository.ExperienceRepository;
import com.careeros.experience.service.ExperienceService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ExperienceServiceImpl implements ExperienceService {

    private final ExperienceRepository experienceRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public ExperienceServiceImpl(
            ExperienceRepository experienceRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.experienceRepository = experienceRepository;
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
    public ExperienceResponse createExperience(
            ExperienceRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Experience experience = new Experience();

        experience.setUserProfile(userProfile);

        ExperienceMapper.mapRequestToEntity(
                request,
                experience
        );

        Experience savedExperience =
                experienceRepository.save(experience);

        return ExperienceMapper.mapEntityToResponse(savedExperience);
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.List<ExperienceResponse> getMyExperiences() {

        UserProfile userProfile = getCurrentUserProfile();

        return experienceRepository.findByUserProfile(userProfile)
                .stream()
                .map(ExperienceMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ExperienceResponse getExperienceById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Experience experience = experienceRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ExperienceNotFoundException(
                                "Experience not found."
                        )
                );

        return ExperienceMapper.mapEntityToResponse(experience);
    }
    @Override
    public ExperienceResponse updateExperience(
            Long id,
            ExperienceRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Experience experience = experienceRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ExperienceNotFoundException(
                                "Experience not found."
                        )
                );

        ExperienceMapper.mapRequestToEntity(
                request,
                experience
        );

        Experience updatedExperience =
                experienceRepository.save(experience);

        return ExperienceMapper.mapEntityToResponse(updatedExperience);
    }

    @Override
    public void deleteExperience(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Experience experience = experienceRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ExperienceNotFoundException(
                                "Experience not found."
                        )
                );

        experienceRepository.delete(experience);
    }
}