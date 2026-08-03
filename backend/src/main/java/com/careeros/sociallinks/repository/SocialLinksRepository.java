package com.careeros.sociallinks.repository;

import com.careeros.sociallinks.entity.SocialLinks;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SocialLinksRepository
        extends JpaRepository<SocialLinks, Long> {

    Optional<SocialLinks> findByUserProfile(
            UserProfile userProfile
    );
}