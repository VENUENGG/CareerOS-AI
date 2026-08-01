package com.careeros.project.service;

import com.careeros.project.dto.ProjectRequest;
import com.careeros.project.dto.ProjectResponse;

import java.util.List;

public interface ProjectService {

    ProjectResponse createProject(
            ProjectRequest request
    );

    List<ProjectResponse> getMyProjects();

    ProjectResponse getProjectById(Long id);

    ProjectResponse updateProject(
            Long id,
            ProjectRequest request
    );

    void deleteProject(Long id);
}