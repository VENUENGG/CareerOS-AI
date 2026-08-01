package com.careeros.project.mapper;

import com.careeros.project.dto.ProjectRequest;
import com.careeros.project.dto.ProjectResponse;
import com.careeros.project.entity.Project;

public class ProjectMapper {

    private ProjectMapper() {
    }

    public static void mapRequestToEntity(
            ProjectRequest request,
            Project project
    ) {

        project.setProjectName(request.getProjectName());
        project.setDescription(request.getDescription());
        project.setTechnologies(request.getTechnologies());
        project.setGithubUrl(request.getGithubUrl());
        project.setLiveUrl(request.getLiveUrl());
        project.setCurrentlyWorking(request.getCurrentlyWorking());
        project.setStartDate(request.getStartDate());
        project.setEndDate(request.getEndDate());
    }

    public static ProjectResponse mapEntityToResponse(
            Project project
    ) {

        ProjectResponse response = new ProjectResponse();

        response.setId(project.getId());
        response.setProjectName(project.getProjectName());
        response.setDescription(project.getDescription());
        response.setTechnologies(project.getTechnologies());
        response.setGithubUrl(project.getGithubUrl());
        response.setLiveUrl(project.getLiveUrl());
        response.setCurrentlyWorking(project.getCurrentlyWorking());
        response.setStartDate(project.getStartDate());
        response.setEndDate(project.getEndDate());
        response.setCreatedAt(project.getCreatedAt());
        response.setUpdatedAt(project.getUpdatedAt());

        return response;
    }
}