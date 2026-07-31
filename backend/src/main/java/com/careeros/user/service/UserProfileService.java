package com.careeros.user.service;

import com.careeros.user.dto.UserProfileRequest;
import com.careeros.user.dto.UserProfileResponse;

public interface UserProfileService {

    UserProfileResponse createProfile(UserProfileRequest request);

    UserProfileResponse getMyProfile();

    UserProfileResponse updateProfile(UserProfileRequest request);
}