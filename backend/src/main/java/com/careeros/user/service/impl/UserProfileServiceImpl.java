package com.careeros.user.service.impl;

import com.careeros.exception.ProfileAlreadyExistsException;
import com.careeros.exception.ProfileNotFoundException;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.dto.UserProfileRequest;
import com.careeros.user.dto.UserProfileResponse;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.mapper.UserProfileMapper;
import com.careeros.user.repository.UserProfileRepository;
import com.careeros.user.service.UserProfileService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserProfileServiceImpl implements UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public UserProfileServiceImpl(
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
    }

    @Override
    public UserProfileResponse createProfile(UserProfileRequest request) {

        User currentUser = authenticatedUserService.getCurrentUser();

        if (userProfileRepository.existsByUser(currentUser)) {
            throw new ProfileAlreadyExistsException("Profile already exists.");
        }

        UserProfile profile = new UserProfile();
        profile.setUser(currentUser);

        UserProfileMapper.mapRequestToEntity(request, profile);

        UserProfile savedProfile = userProfileRepository.save(profile);

        return UserProfileMapper.mapEntityToResponse(savedProfile);
    }

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getMyProfile() {

        User currentUser = authenticatedUserService.getCurrentUser();

        UserProfile profile = userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new ProfileNotFoundException("Profile not found.")
                );

        return UserProfileMapper.mapEntityToResponse(profile);
    }

    @Override
    public UserProfileResponse updateProfile(UserProfileRequest request) {

        User currentUser = authenticatedUserService.getCurrentUser();

        UserProfile profile = userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new ProfileNotFoundException("Profile not found.")
                );

        UserProfileMapper.mapRequestToEntity(request, profile);

        UserProfile updatedProfile = userProfileRepository.save(profile);

        return UserProfileMapper.mapEntityToResponse(updatedProfile);
    }
}