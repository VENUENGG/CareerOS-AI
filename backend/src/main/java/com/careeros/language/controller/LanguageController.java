package com.careeros.language.controller;

import com.careeros.language.dto.LanguageRequest;
import com.careeros.language.dto.LanguageResponse;
import com.careeros.language.service.LanguageService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/languages")
public class LanguageController {

    private final LanguageService languageService;

    public LanguageController(
            LanguageService languageService
    ) {
        this.languageService = languageService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public LanguageResponse createLanguage(
            @Valid @RequestBody LanguageRequest request
    ) {
        return languageService.createLanguage(request);
    }

    @GetMapping
    public List<LanguageResponse> getMyLanguages() {
        return languageService.getMyLanguages();
    }

    @GetMapping("/{id}")
    public LanguageResponse getLanguageById(
            @PathVariable Long id
    ) {
        return languageService.getLanguageById(id);
    }

    @PutMapping("/{id}")
    public LanguageResponse updateLanguage(
            @PathVariable Long id,
            @Valid @RequestBody LanguageRequest request
    ) {
        return languageService.updateLanguage(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteLanguage(
            @PathVariable Long id
    ) {
        languageService.deleteLanguage(id);
    }
}