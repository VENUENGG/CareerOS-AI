package com.careeros.sociallinks.service.impl;

import com.careeros.exception.SocialLinksAlreadyExistsException;
import com.careeros.exception.SocialLinksNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.sociallinks.dto.SocialLinksRequest;
import com.careeros.sociallinks.dto.SocialLinksResponse;
import com.careeros.sociallinks.entity.SocialLinks;
import com.careeros.sociallinks.mapper.SocialLinksMapper;
import com.careeros.sociallinks.repository.SocialLinksRepository;
import com.careeros.sociallinks.service.SocialLinksService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class SocialLinksServiceImpl implements SocialLinksService {

    private final SocialLinksRepository socialLinksRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public SocialLinksServiceImpl(
            SocialLinksRepository socialLinksRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.socialLinksRepository = socialLinksRepository;
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
    public SocialLinksResponse createSocialLinks(
            SocialLinksRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        if (socialLinksRepository.findByUserProfile(userProfile).isPresent()) {
            throw new SocialLinksAlreadyExistsException(
                    "Social links already exist."
            );
        }

        SocialLinks socialLinks = new SocialLinks();

        socialLinks.setUserProfile(userProfile);

        SocialLinksMapper.mapRequestToEntity(
                request,
                socialLinks
        );

        SocialLinks saved =
                socialLinksRepository.save(socialLinks);

        return SocialLinksMapper.mapEntityToResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public SocialLinksResponse getMySocialLinks() {

        UserProfile userProfile = getCurrentUserProfile();

        SocialLinks socialLinks = socialLinksRepository
                .findByUserProfile(userProfile)
                .orElseThrow(() ->
                        new SocialLinksNotFoundException(
                                "Social links not found."
                        )
                );

        return SocialLinksMapper.mapEntityToResponse(socialLinks);
    }

    @Override
    public SocialLinksResponse updateSocialLinks(
            SocialLinksRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        SocialLinks socialLinks = socialLinksRepository
                .findByUserProfile(userProfile)
                .orElseThrow(() ->
                        new SocialLinksNotFoundException(
                                "Social links not found."
                        )
                );

        SocialLinksMapper.mapRequestToEntity(
                request,
                socialLinks
        );

        SocialLinks updated =
                socialLinksRepository.save(socialLinks);

        return SocialLinksMapper.mapEntityToResponse(updated);
    }

    @Override
    public void deleteSocialLinks() {

        UserProfile userProfile = getCurrentUserProfile();

        SocialLinks socialLinks = socialLinksRepository
                .findByUserProfile(userProfile)
                .orElseThrow(() ->
                        new SocialLinksNotFoundException(
                                "Social links not found."
                        )
                );

        socialLinksRepository.delete(socialLinks);
    }
}