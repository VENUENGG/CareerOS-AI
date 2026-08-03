package com.careeros.resumeselection.repository;

import com.careeros.resume.entity.Resume;
import com.careeros.resumeselection.entity.ResumeSelection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ResumeSelectionRepository extends JpaRepository<ResumeSelection, Long> {

    Optional<ResumeSelection> findByResume(Resume resume);

    Optional<ResumeSelection> findByResumeId(Long resumeId);
}