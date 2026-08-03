package com.careeros.sociallinks.controller;

import com.careeros.sociallinks.dto.SocialLinksRequest;
import com.careeros.sociallinks.dto.SocialLinksResponse;
import com.careeros.sociallinks.service.SocialLinksService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/social-links")
public class SocialLinksController {

    private final SocialLinksService socialLinksService;

    public SocialLinksController(
            SocialLinksService socialLinksService
    ) {
        this.socialLinksService = socialLinksService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SocialLinksResponse createSocialLinks(
            @Valid @RequestBody SocialLinksRequest request
    ) {
        return socialLinksService.createSocialLinks(request);
    }

    @GetMapping
    public SocialLinksResponse getMySocialLinks() {
        return socialLinksService.getMySocialLinks();
    }

    @PutMapping
    public SocialLinksResponse updateSocialLinks(
            @Valid @RequestBody SocialLinksRequest request
    ) {
        return socialLinksService.updateSocialLinks(request);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteSocialLinks() {
        socialLinksService.deleteSocialLinks();
    }
}