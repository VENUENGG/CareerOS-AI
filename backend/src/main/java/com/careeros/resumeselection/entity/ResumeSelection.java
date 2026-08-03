package com.careeros.resumeselection.entity;

import com.careeros.resume.entity.Resume;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "resume_selections")
@Getter
@Setter
public class ResumeSelection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resume_id", nullable = false, unique = true)
    private Resume resume;

    @ElementCollection
    @CollectionTable(
            name = "resume_selected_skills",
            joinColumns = @JoinColumn(name = "resume_selection_id")
    )
    @Column(name = "skill_id")
    private Set<Long> skillIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "resume_selected_projects",
            joinColumns = @JoinColumn(name = "resume_selection_id")
    )
    @Column(name = "project_id")
    private Set<Long> projectIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "resume_selected_experiences",
            joinColumns = @JoinColumn(name = "resume_selection_id")
    )
    @Column(name = "experience_id")
    private Set<Long> experienceIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "resume_selected_certifications",
            joinColumns = @JoinColumn(name = "resume_selection_id")
    )
    @Column(name = "certification_id")
    private Set<Long> certificationIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "resume_selected_languages",
            joinColumns = @JoinColumn(name = "resume_selection_id")
    )
    @Column(name = "language_id")
    private Set<Long> languageIds = new HashSet<>();
}