package com.careeros.salary.repository;

import com.careeros.salary.entity.SalaryBenchmark;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SalaryBenchmarkRepository
        extends JpaRepository<SalaryBenchmark, Long> {

    Optional<SalaryBenchmark> findByJobTitleIgnoreCaseAndLocationIgnoreCaseAndExperienceLevelIgnoreCaseAndIndustryIgnoreCase(
            String jobTitle,
            String location,
            String experienceLevel,
            String industry
    );
}