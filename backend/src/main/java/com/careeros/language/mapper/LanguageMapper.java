package com.careeros.language.mapper;

import com.careeros.language.dto.LanguageRequest;
import com.careeros.language.dto.LanguageResponse;
import com.careeros.language.entity.Language;

public class LanguageMapper {

    private LanguageMapper() {
    }

    public static void mapRequestToEntity(
            LanguageRequest request,
            Language language
    ) {

        language.setLanguageName(request.getLanguageName());
        language.setProficiency(request.getProficiency());
    }

    public static LanguageResponse mapEntityToResponse(
            Language language
    ) {

        LanguageResponse response = new LanguageResponse();

        response.setId(language.getId());
        response.setLanguageName(language.getLanguageName());
        response.setProficiency(language.getProficiency());
        response.setCreatedAt(language.getCreatedAt());
        response.setUpdatedAt(language.getUpdatedAt());

        return response;
    }
}