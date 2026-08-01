package com.careeros.skill.dto;

import com.careeros.skill.enums.SkillProficiency;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SkillRequest {

    @NotBlank(message = "Skill name is required.")
    private String skillName;

    @NotNull(message = "Proficiency is required.")
    private SkillProficiency proficiency;
}