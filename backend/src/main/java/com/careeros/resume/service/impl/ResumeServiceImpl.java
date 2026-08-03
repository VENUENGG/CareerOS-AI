package com.careeros.resume.service.impl;

import com.careeros.exception.ResumeNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.resume.dto.ResumeRequest;
import com.careeros.resume.dto.ResumeResponse;
import com.careeros.resume.entity.Resume;
import com.careeros.resume.mapper.ResumeMapper;
import com.careeros.resume.repository.ResumeRepository;
import com.careeros.resume.service.ResumeService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class ResumeServiceImpl implements ResumeService {

    private final ResumeRepository resumeRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public ResumeServiceImpl(
            ResumeRepository resumeRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.resumeRepository = resumeRepository;
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
    public ResumeResponse createResume(
            ResumeRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Resume resume = new Resume();

        resume.setUserProfile(userProfile);

        ResumeMapper.mapRequestToEntity(
                request,
                resume
        );

        Resume savedResume =
                resumeRepository.save(resume);

        return ResumeMapper.mapEntityToResponse(savedResume);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ResumeResponse> getMyResumes() {

        UserProfile userProfile = getCurrentUserProfile();

        return resumeRepository.findByUserProfile(userProfile)
                .stream()
                .map(ResumeMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ResumeResponse getResumeById(
            Long id
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Resume resume = resumeRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ResumeNotFoundException(
                                "Resume not found."
                        )
                );

        return ResumeMapper.mapEntityToResponse(resume);
    }

    @Override
    public ResumeResponse updateResume(
            Long id,
            ResumeRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Resume resume = resumeRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ResumeNotFoundException(
                                "Resume not found."
                        )
                );

        ResumeMapper.mapRequestToEntity(
                request,
                resume
        );

        Resume updatedResume =
                resumeRepository.save(resume);

        return ResumeMapper.mapEntityToResponse(updatedResume);
    }

    @Override
    public void deleteResume(
            Long id
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Resume resume = resumeRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new ResumeNotFoundException(
                                "Resume not found."
                        )
                );

        resumeRepository.delete(resume);
    }
}