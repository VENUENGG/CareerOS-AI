package com.careeros.salary.entity;

import com.careeros.user.entity.UserProfile;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(
        name = "salary_analyses",
        indexes = {
                @Index(name = "idx_salary_analysis_profile",
                        columnList = "user_profile_id")
        }
)
@Getter
@Setter
public class SalaryAnalysis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_profile_id", nullable = false)
    private UserProfile userProfile;

    @Column(name = "job_title", nullable = false, length = 150)
    private String jobTitle;

    @Column(nullable = false, length = 150)
    private String location;

    @Column(nullable = false, length = 100)
    private String industry;

    @Column(name = "experience_years", nullable = false)
    private Integer experienceYears;

    @Column(name = "minimum_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal minimumSalary;

    @Column(name = "expected_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal expectedSalary;

    @Column(name = "maximum_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal maximumSalary;

    @Column(nullable = false, length = 10)
    private String currency;

    @Column(name = "current_salary", precision = 12, scale = 2)
    private BigDecimal currentSalary;

    @Column(name = "market_position", length = 50)
    private String marketPosition;

    @ElementCollection
    @CollectionTable(
            name = "salary_analysis_factors",
            joinColumns = @JoinColumn(name = "salary_analysis_id")
    )
    @Column(name = "factor", nullable = false, length = 500)
    private Set<String> factors = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "salary_analysis_skills",
            joinColumns = @JoinColumn(name = "salary_analysis_id")
    )
    @Column(name = "skill_name", nullable = false, length = 150)
    private Set<String> skillNames = new HashSet<>();

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}