package com.careeros.experience.mapper;

import com.careeros.experience.dto.ExperienceRequest;
import com.careeros.experience.dto.ExperienceResponse;
import com.careeros.experience.entity.Experience;

public class ExperienceMapper {

    private ExperienceMapper() {
    }

    public static void mapRequestToEntity(
            ExperienceRequest request,
            Experience experience
    ) {

        experience.setCompanyName(request.getCompanyName());
        experience.setJobTitle(request.getJobTitle());
        experience.setEmploymentType(request.getEmploymentType());
        experience.setLocation(request.getLocation());
        experience.setCurrentlyWorking(request.getCurrentlyWorking());
        experience.setStartDate(request.getStartDate());
        experience.setEndDate(request.getEndDate());
        experience.setDescription(request.getDescription());
    }

    public static ExperienceResponse mapEntityToResponse(
            Experience experience
    ) {

        ExperienceResponse response = new ExperienceResponse();

        response.setId(experience.getId());
        response.setCompanyName(experience.getCompanyName());
        response.setJobTitle(experience.getJobTitle());
        response.setEmploymentType(experience.getEmploymentType());
        response.setLocation(experience.getLocation());
        response.setCurrentlyWorking(experience.getCurrentlyWorking());
        response.setStartDate(experience.getStartDate());
        response.setEndDate(experience.getEndDate());
        response.setDescription(experience.getDescription());
        response.setCreatedAt(experience.getCreatedAt());
        response.setUpdatedAt(experience.getUpdatedAt());

        return response;
    }
}