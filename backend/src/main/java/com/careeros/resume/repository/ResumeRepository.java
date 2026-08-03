package com.careeros.resume.repository;

import com.careeros.resume.entity.Resume;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ResumeRepository extends JpaRepository<Resume, Long> {

    List<Resume> findByUserProfile(UserProfile userProfile);

    Optional<Resume> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}