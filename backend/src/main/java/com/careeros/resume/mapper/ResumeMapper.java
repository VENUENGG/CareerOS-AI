package com.careeros.resume.mapper;

import com.careeros.resume.dto.ResumeRequest;
import com.careeros.resume.dto.ResumeResponse;
import com.careeros.resume.entity.Resume;

public class ResumeMapper {

    private ResumeMapper() {
    }

    public static void mapRequestToEntity(
            ResumeRequest request,
            Resume resume
    ) {

        resume.setTitle(request.getTitle());
        resume.setTemplateType(request.getTemplateType());
        resume.setProfessionalSummary(request.getProfessionalSummary());
        resume.setIsPublic(request.getIsPublic());
    }

    public static ResumeResponse mapEntityToResponse(
            Resume resume
    ) {

        ResumeResponse response = new ResumeResponse();

        response.setId(resume.getId());
        response.setTitle(resume.getTitle());
        response.setTemplateType(resume.getTemplateType());
        response.setProfessionalSummary(resume.getProfessionalSummary());
        response.setIsPublic(resume.getIsPublic());
        response.setCreatedAt(resume.getCreatedAt());
        response.setUpdatedAt(resume.getUpdatedAt());

        return response;
    }
}