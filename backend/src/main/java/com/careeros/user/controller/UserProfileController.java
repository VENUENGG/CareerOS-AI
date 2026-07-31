package com.careeros.user.controller;

import com.careeros.common.constants.MessageConstants;
import com.careeros.common.response.ApiResponse;
import com.careeros.user.dto.UserProfileRequest;
import com.careeros.user.dto.UserProfileResponse;
import com.careeros.user.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/profile")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<UserProfileResponse>> createProfile(
            @Valid @RequestBody UserProfileRequest request
    ) {

        UserProfileResponse response =
                userProfileService.createProfile(request);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        true,
                        MessageConstants.PROFILE_CREATED_SUCCESSFULLY,
                        response
                ));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getMyProfile() {

        UserProfileResponse response =
                userProfileService.getMyProfile();

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        MessageConstants.PROFILE_FETCHED_SUCCESSFULLY,
                        response
                )
        );
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateProfile(
            @Valid @RequestBody UserProfileRequest request
    ) {

        UserProfileResponse response =
                userProfileService.updateProfile(request);

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        MessageConstants.PROFILE_UPDATED_SUCCESSFULLY,
                        response
                )
        );
    }
}