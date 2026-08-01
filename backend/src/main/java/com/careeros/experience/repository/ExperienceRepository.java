package com.careeros.experience.repository;

import com.careeros.experience.entity.Experience;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ExperienceRepository extends JpaRepository<Experience, Long> {

    List<Experience> findByUserProfile(UserProfile userProfile);

    Optional<Experience> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}