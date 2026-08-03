package com.careeros.language.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class LanguageResponse {

    private Long id;

    private String languageName;

    private String proficiency;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}