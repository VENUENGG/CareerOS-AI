package com.careeros.education.repository;

import com.careeros.education.entity.Education;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EducationRepository extends JpaRepository<Education, Long> {

    List<Education> findByUserProfile(UserProfile userProfile);

    Optional<Education> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}