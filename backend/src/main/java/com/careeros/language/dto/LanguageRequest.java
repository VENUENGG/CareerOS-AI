package com.careeros.language.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LanguageRequest {

    @NotBlank(message = "Language name is required.")
    private String languageName;

    @NotBlank(message = "Proficiency is required.")
    private String proficiency;
}