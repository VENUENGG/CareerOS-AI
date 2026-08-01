package com.careeros.skill.dto;

import com.careeros.skill.enums.SkillProficiency;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class SkillResponse {

    private Long id;

    private String skillName;

    private SkillProficiency proficiency;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}