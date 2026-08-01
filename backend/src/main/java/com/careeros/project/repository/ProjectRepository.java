package com.careeros.project.repository;

import com.careeros.project.entity.Project;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProjectRepository extends JpaRepository<Project, Long> {

    List<Project> findByUserProfile(
            UserProfile userProfile
    );

    Optional<Project> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}