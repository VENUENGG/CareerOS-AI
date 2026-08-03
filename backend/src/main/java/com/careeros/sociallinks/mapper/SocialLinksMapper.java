package com.careeros.sociallinks.mapper;

import com.careeros.sociallinks.dto.SocialLinksRequest;
import com.careeros.sociallinks.dto.SocialLinksResponse;
import com.careeros.sociallinks.entity.SocialLinks;

public class SocialLinksMapper {

    private SocialLinksMapper() {
    }

    public static void mapRequestToEntity(
            SocialLinksRequest request,
            SocialLinks socialLinks
    ) {

        socialLinks.setGithubUrl(request.getGithubUrl());
        socialLinks.setLinkedinUrl(request.getLinkedinUrl());
        socialLinks.setPortfolioUrl(request.getPortfolioUrl());
        socialLinks.setLeetcodeUrl(request.getLeetcodeUrl());
        socialLinks.setHackerrankUrl(request.getHackerrankUrl());
        socialLinks.setCodeforcesUrl(request.getCodeforcesUrl());
        socialLinks.setCodechefUrl(request.getCodechefUrl());
        socialLinks.setTwitterUrl(request.getTwitterUrl());
        socialLinks.setPersonalWebsite(request.getPersonalWebsite());
    }

    public static SocialLinksResponse mapEntityToResponse(
            SocialLinks socialLinks
    ) {

        SocialLinksResponse response = new SocialLinksResponse();

        response.setId(socialLinks.getId());
        response.setGithubUrl(socialLinks.getGithubUrl());
        response.setLinkedinUrl(socialLinks.getLinkedinUrl());
        response.setPortfolioUrl(socialLinks.getPortfolioUrl());
        response.setLeetcodeUrl(socialLinks.getLeetcodeUrl());
        response.setHackerrankUrl(socialLinks.getHackerrankUrl());
        response.setCodeforcesUrl(socialLinks.getCodeforcesUrl());
        response.setCodechefUrl(socialLinks.getCodechefUrl());
        response.setTwitterUrl(socialLinks.getTwitterUrl());
        response.setPersonalWebsite(socialLinks.getPersonalWebsite());
        response.setCreatedAt(socialLinks.getCreatedAt());
        response.setUpdatedAt(socialLinks.getUpdatedAt());

        return response;
    }
}