package com.careeros.language.repository;

import com.careeros.language.entity.Language;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LanguageRepository
        extends JpaRepository<Language, Long> {

    List<Language> findByUserProfile(
            UserProfile userProfile
    );

    Optional<Language> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}