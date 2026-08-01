package com.careeros.skill.service;

import com.careeros.skill.dto.SkillRequest;
import com.careeros.skill.dto.SkillResponse;

import java.util.List;

public interface SkillService {

    SkillResponse createSkill(
            SkillRequest request
    );

    List<SkillResponse> getMySkills();

    SkillResponse getSkillById(Long id);

    SkillResponse updateSkill(
            Long id,
            SkillRequest request
    );

    void deleteSkill(Long id);
}