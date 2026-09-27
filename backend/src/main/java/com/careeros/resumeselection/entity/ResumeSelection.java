package com.careeros.resumeselection.entity;

import com.careeros.resume.entity.Resume;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
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

    /*
     * Resume associated with this selection.
     * One resume can have only one selection configuration.
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "resume_id",
            nullable = false,
            unique = true
    )
    private Resume resume;

    /*
     * Selected skills for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_skills",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "skill_id")
    private Set<Long> skillIds = new HashSet<>();

    /*
     * Selected projects for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_projects",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "project_id")
    private Set<Long> projectIds = new HashSet<>();

    /*
     * Selected experiences for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_experiences",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "experience_id")
    private Set<Long> experienceIds = new HashSet<>();

    /*
     * Selected education records for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_educations",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "education_id")
    private Set<Long> educationIds = new HashSet<>();

    /*
     * Selected certifications for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_certifications",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "certification_id")
    private Set<Long> certificationIds = new HashSet<>();

    /*
     * Selected languages for this resume.
     */
    @ElementCollection
    @CollectionTable(
            name = "resume_selected_languages",
            joinColumns = @JoinColumn(
                    name = "resume_selection_id"
            )
    )
    @Column(name = "language_id")
    private Set<Long> languageIds = new HashSet<>();
}