package com.careeros.salary.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "salary_benchmarks",
        indexes = {
                @Index(name = "idx_salary_benchmark_lookup",
                        columnList = "job_title,location,experience_level,industry")
        }
)
@Getter
@Setter
public class SalaryBenchmark {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "job_title", nullable = false, length = 150)
    private String jobTitle;

    @Column(nullable = false, length = 150)
    private String location;

    @Column(name = "experience_level", nullable = false, length = 50)
    private String experienceLevel;

    @Column(nullable = false, length = 100)
    private String industry;

    @Column(name = "minimum_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal minimumSalary;

    @Column(name = "median_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal medianSalary;

    @Column(name = "maximum_salary", nullable = false, precision = 12, scale = 2)
    private BigDecimal maximumSalary;

    @Column(nullable = false, length = 10)
    private String currency = "INR";

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