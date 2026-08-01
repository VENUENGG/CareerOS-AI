package com.careeros.education.mapper;

import com.careeros.education.dto.EducationRequest;
import com.careeros.education.dto.EducationResponse;
import com.careeros.education.entity.Education;

public class EducationMapper {

    private EducationMapper() {
    }

    public static void mapRequestToEntity(
            EducationRequest request,
            Education education
    ) {
        education.setInstitutionName(request.getInstitutionName());
        education.setDegree(request.getDegree());
        education.setFieldOfStudy(request.getFieldOfStudy());
        education.setGrade(request.getGrade());
        education.setStartDate(request.getStartDate());
        education.setEndDate(request.getEndDate());
        education.setCurrentlyStudying(request.getCurrentlyStudying());
        education.setDescription(request.getDescription());
    }

    public static EducationResponse mapEntityToResponse(
            Education education
    ) {
        EducationResponse response = new EducationResponse();

        response.setId(education.getId());
        response.setInstitutionName(education.getInstitutionName());
        response.setDegree(education.getDegree());
        response.setFieldOfStudy(education.getFieldOfStudy());
        response.setGrade(education.getGrade());
        response.setStartDate(education.getStartDate());
        response.setEndDate(education.getEndDate());
        response.setCurrentlyStudying(education.getCurrentlyStudying());
        response.setDescription(education.getDescription());

        return response;
    }
}
