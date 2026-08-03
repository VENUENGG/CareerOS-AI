package com.careeros.language.service.impl;

import com.careeros.exception.LanguageNotFoundException;
import com.careeros.exception.UserProfileNotFoundException;
import com.careeros.language.dto.LanguageRequest;
import com.careeros.language.dto.LanguageResponse;
import com.careeros.language.entity.Language;
import com.careeros.language.mapper.LanguageMapper;
import com.careeros.language.repository.LanguageRepository;
import com.careeros.language.service.LanguageService;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class LanguageServiceImpl implements LanguageService {

    private final LanguageRepository languageRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuthenticatedUserService authenticatedUserService;

    public LanguageServiceImpl(
            LanguageRepository languageRepository,
            UserProfileRepository userProfileRepository,
            AuthenticatedUserService authenticatedUserService
    ) {
        this.languageRepository = languageRepository;
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

    }@Override
    public LanguageResponse createLanguage(
            LanguageRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Language language = new Language();

        language.setUserProfile(userProfile);

        LanguageMapper.mapRequestToEntity(
                request,
                language
        );

        Language savedLanguage =
                languageRepository.save(language);

        return LanguageMapper.mapEntityToResponse(savedLanguage);
    }

    @Override
    @Transactional(readOnly = true)
    public java.util.List<LanguageResponse> getMyLanguages() {

        UserProfile userProfile = getCurrentUserProfile();

        return languageRepository.findByUserProfile(userProfile)
                .stream()
                .map(LanguageMapper::mapEntityToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public LanguageResponse getLanguageById(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Language language = languageRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new LanguageNotFoundException(
                                "Language not found."
                        )
                );

        return LanguageMapper.mapEntityToResponse(language);
    }

    @Override
    public LanguageResponse updateLanguage(
            Long id,
            LanguageRequest request
    ) {

        UserProfile userProfile = getCurrentUserProfile();

        Language language = languageRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new LanguageNotFoundException(
                                "Language not found."
                        )
                );

        LanguageMapper.mapRequestToEntity(
                request,
                language
        );

        Language updatedLanguage =
                languageRepository.save(language);

        return LanguageMapper.mapEntityToResponse(updatedLanguage);
    }

    @Override
    public void deleteLanguage(Long id) {

        UserProfile userProfile = getCurrentUserProfile();

        Language language = languageRepository
                .findByIdAndUserProfile(id, userProfile)
                .orElseThrow(() ->
                        new LanguageNotFoundException(
                                "Language not found."
                        )
                );

        languageRepository.delete(language);
    }
}
