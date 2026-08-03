package com.careeros.sociallinks.entity;

import com.careeros.user.entity.UserProfile;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "social_links")
@Getter
@Setter
public class SocialLinks {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_profile_id", nullable = false, unique = true)
    private UserProfile userProfile;

    private String githubUrl;

    private String linkedinUrl;

    private String portfolioUrl;

    private String leetcodeUrl;

    private String hackerrankUrl;

    private String codeforcesUrl;

    private String codechefUrl;

    private String twitterUrl;

    private String personalWebsite;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}