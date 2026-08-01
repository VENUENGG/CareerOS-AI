package com.careeros.skill.repository;

import com.careeros.skill.entity.Skill;
import com.careeros.user.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SkillRepository extends JpaRepository<Skill, Long> {

    List<Skill> findByUserProfile(UserProfile userProfile);

    Optional<Skill> findByIdAndUserProfile(
            Long id,
            UserProfile userProfile
    );
}