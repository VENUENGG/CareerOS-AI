package com.careeros.language.service;

import com.careeros.language.dto.LanguageRequest;
import com.careeros.language.dto.LanguageResponse;

import java.util.List;

public interface LanguageService {

    LanguageResponse createLanguage(
            LanguageRequest request
    );

    List<LanguageResponse> getMyLanguages();

    LanguageResponse getLanguageById(Long id);

    LanguageResponse updateLanguage(
            Long id,
            LanguageRequest request
    );

    void deleteLanguage(Long id);
}