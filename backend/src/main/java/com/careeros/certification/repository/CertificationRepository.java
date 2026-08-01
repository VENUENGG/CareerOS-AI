package com.careeros.certification.repository;

import com.careeros.certification.entity.Certification;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CertificationRepository
        extends JpaRepository<Certification, Long> {

    List<Certification> findByUserProfile(
            UserProfile userProfile
    );

    Optional<Certification> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}