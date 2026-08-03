package com.careeros.resumeselection.service.impl;

import com.careeros.exception.ResumeNotFoundException;
import com.careeros.exception.ResumeSelectionNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.resume.entity.Resume;
import com.careeros.resume.repository.ResumeRepository;
import com.careeros.resumeselection.dto.ResumeSelectionRequest;
import com.careeros.resumeselection.dto.ResumeSelectionResponse;
import com.careeros.resumeselection.entity.ResumeSelection;
import com.careeros.resumeselection.mapper.ResumeSelectionMapper;
import com.careeros.resumeselection.repository.ResumeSelectionRepository;
import com.careeros.resumeselection.service.ResumeSelectionService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ResumeSelectionServiceImpl implements ResumeSelectionService {

    private final ResumeSelectionRepository resumeSelectionRepository;
    private final ResumeRepository resumeRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public ResumeSelectionServiceImpl(
            ResumeSelectionRepository resumeSelectionRepository,
            ResumeRepository resumeRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.resumeSelectionRepository = resumeSelectionRepository;
        this.resumeRepository = resumeRepository;
        this.userProfileRepository = userProfileRepository;
        this.authenticatedUserService = authenticatedUserService;
    }

    private UserProfile getCurrentUserProfile() {

        User currentUser = authenticatedUserService.getCurrentUser();

        return userProfileRepository.findByUser(currentUser)
                .orElseThrow(() ->
                        new UserProfileNotFoundException("User profile not found."));
    }

    private Resume getOwnedResume(Long resumeId) {

        UserProfile profile = getCurrentUserProfile();

        return resumeRepository.findByIdAndUserProfile(resumeId, profile)
                .orElseThrow(() ->
                        new ResumeNotFoundException("Resume not found."));
    }

    @Override
    public ResumeSelectionResponse saveSelections(
            Long resumeId,
            ResumeSelectionRequest request
    ) {

        Resume resume = getOwnedResume(resumeId);

        ResumeSelection selection = resumeSelectionRepository
                .findByResume(resume)
                .orElseGet(() -> {
                    ResumeSelection newSelection = new ResumeSelection();
                    newSelection.setResume(resume);
                    return newSelection;
                });

        ResumeSelectionMapper.mapRequestToEntity(request, selection);

        ResumeSelection saved =
                resumeSelectionRepository.save(selection);

        return ResumeSelectionMapper.mapEntityToResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public ResumeSelectionResponse getSelections(
            Long resumeId
    ) {

        Resume resume = getOwnedResume(resumeId);

        ResumeSelection selection = resumeSelectionRepository
                .findByResume(resume)
                .orElseThrow(() ->
                        new ResumeSelectionNotFoundException(
                                "Resume selection not found."
                        ));

        return ResumeSelectionMapper.mapEntityToResponse(selection);
    }
}