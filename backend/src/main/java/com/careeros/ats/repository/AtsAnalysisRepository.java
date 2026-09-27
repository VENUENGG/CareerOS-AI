package com.careeros.ats.repository;

import com.careeros.ats.entity.AtsAnalysis;
import com.careeros.resume.entity.Resume;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AtsAnalysisRepository extends JpaRepository<AtsAnalysis, Long> {

    Optional<AtsAnalysis> findFirstByResumeOrderByCreatedAtDesc(
            Resume resume
    );

    List<AtsAnalysis> findByResumeOrderByCreatedAtDesc(
            Resume resume
    );
}