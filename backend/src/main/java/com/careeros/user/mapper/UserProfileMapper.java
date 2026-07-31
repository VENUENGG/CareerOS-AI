package com.careeros.user.mapper;

import com.careeros.user.dto.UserProfileRequest;
import com.careeros.user.dto.UserProfileResponse;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;

public class UserProfileMapper {

    private UserProfileMapper() {
    }

    public static void mapRequestToEntity(UserProfileRequest request, UserProfile profile) {

        profile.setPhone(request.getPhone());
        profile.setDateOfBirth(request.getDateOfBirth());
        profile.setGender(request.getGender());
        profile.setHeadline(request.getHeadline());
        profile.setBio(request.getBio());
        profile.setCurrentJobTitle(request.getCurrentJobTitle());
        profile.setYearsOfExperience(request.getYearsOfExperience());
        profile.setCity(request.getCity());
        profile.setState(request.getState());
        profile.setCountry(request.getCountry());
        profile.setLinkedinUrl(request.getLinkedinUrl());
        profile.setGithubUrl(request.getGithubUrl());
        profile.setPortfolioUrl(request.getPortfolioUrl());
    }

    public static UserProfileResponse mapEntityToResponse(UserProfile profile) {

        User user = profile.getUser();

        UserProfileResponse response = new UserProfileResponse();

        response.setId(profile.getId());
        response.setUserId(user.getId());
        response.setFirstName(user.getFirstName());
        response.setLastName(user.getLastName());
        response.setEmail(user.getEmail());

        response.setPhone(profile.getPhone());
        response.setDateOfBirth(profile.getDateOfBirth());
        response.setGender(profile.getGender());
        response.setHeadline(profile.getHeadline());
        response.setBio(profile.getBio());
        response.setCurrentJobTitle(profile.getCurrentJobTitle());
        response.setYearsOfExperience(profile.getYearsOfExperience());
        response.setCity(profile.getCity());
        response.setState(profile.getState());
        response.setCountry(profile.getCountry());
        response.setLinkedinUrl(profile.getLinkedinUrl());
        response.setGithubUrl(profile.getGithubUrl());
        response.setPortfolioUrl(profile.getPortfolioUrl());
        response.setProfilePhotoUrl(profile.getProfilePhotoUrl());
        response.setCreatedAt(profile.getCreatedAt());
        response.setUpdatedAt(profile.getUpdatedAt());

        return response;
    }
}