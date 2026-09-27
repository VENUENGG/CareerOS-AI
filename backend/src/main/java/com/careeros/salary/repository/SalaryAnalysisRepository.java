package com.careeros.salary.repository;

import com.careeros.salary.entity.SalaryAnalysis;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SalaryAnalysisRepository
        extends JpaRepository<SalaryAnalysis, Long> {

    Optional<SalaryAnalysis>
    findTopByUserProfileOrderByCreatedAtDesc(
            UserProfile userProfile
    );

    List<SalaryAnalysis>
    findAllByUserProfileOrderByCreatedAtDesc(
            UserProfile userProfile
    );
}