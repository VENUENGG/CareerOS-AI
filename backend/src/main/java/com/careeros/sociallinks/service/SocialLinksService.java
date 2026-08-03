package com.careeros.sociallinks.service;

import com.careeros.sociallinks.dto.SocialLinksRequest;
import com.careeros.sociallinks.dto.SocialLinksResponse;

public interface SocialLinksService {

    SocialLinksResponse createSocialLinks(
            SocialLinksRequest request
    );

    SocialLinksResponse getMySocialLinks();

    SocialLinksResponse updateSocialLinks(
            SocialLinksRequest request
    );

    void deleteSocialLinks();
}