package com.careeros.salary.repository;

import com.careeros.salary.entity.SalarySkillPremium;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SalarySkillPremiumRepository
        extends JpaRepository<SalarySkillPremium, Long> {

    List<SalarySkillPremium> findByJobTitleIgnoreCase(
            String jobTitle
    );
}