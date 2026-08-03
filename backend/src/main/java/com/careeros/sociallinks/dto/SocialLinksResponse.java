package com.careeros.sociallinks.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class SocialLinksResponse {

    private Long id;

    private String githubUrl;

    private String linkedinUrl;

    private String portfolioUrl;

    private String leetcodeUrl;

    private String hackerrankUrl;

    private String codeforcesUrl;

    private String codechefUrl;

    private String twitterUrl;

    private String personalWebsite;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}