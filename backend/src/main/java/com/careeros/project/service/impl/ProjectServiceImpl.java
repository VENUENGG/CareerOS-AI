package com.careeros.project.service.impl;

import com.careeros.exception.ProjectNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.project.dto.ProjectRequest;
import com.careeros.project.dto.ProjectResponse;
import com.careeros.project.entity.Project;
import com.careeros.project.mapper.ProjectMapper;
import com.careeros.project.repository.ProjectRepository;
import com.careeros.project.service.ProjectService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public ProjectServiceImpl(
            ProjectRepository projectRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.projectRepository = projectRepository;
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
    public ProjectResponse createProject(ProjectRequest request) {

        UserProfile userProfile = getCurrentUserProfile();

        Project project = new Project();

        project.setUserProfile(userProfile);

        ProjectMapper.mapRequestToEntity(request, project);

        Project savedProject = projectRepository.save(project);

        return ProjectMapper.mapEntityToResponse(savedProject);
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.List<ProjectResponse> getMyProjects() {

        UserProfile userProfile = getCurrentUserProfile();

        return projectRepository.findByUserProfile(userProfile)
                .stream()
                .map(ProjectMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ProjectResponse getProjectById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Project project = projectRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ProjectNotFoundException(
                                "Project not found."
                        )
                );

        return ProjectMapper.mapEntityToResponse(project);
    }

    @Override
    public ProjectResponse updateProject(
            Long id,
            ProjectRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Project project = projectRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ProjectNotFoundException(
                                "Project not found."
                        )
                );

        ProjectMapper.mapRequestToEntity(request, project);

        Project updatedProject = projectRepository.save(project);

        return ProjectMapper.mapEntityToResponse(updatedProject);
    }

    @Override
    public void deleteProject(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Project project = projectRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ProjectNotFoundException(
                                "Project not found."
                        )
                );

        projectRepository.delete(project);
    }
}