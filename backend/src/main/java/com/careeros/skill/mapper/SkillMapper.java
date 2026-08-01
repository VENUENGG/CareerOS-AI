package com.careeros.skill.mapper;

import com.careeros.skill.dto.SkillRequest;
import com.careeros.skill.dto.SkillResponse;
import com.careeros.skill.entity.Skill;

public class SkillMapper {

    private SkillMapper() {
    }

    public static void mapRequestToEntity(
            SkillRequest request,
            Skill skill
    ) {
        skill.setSkillName(request.getSkillName());
        skill.setProficiency(request.getProficiency());
    }

    public static SkillResponse mapEntityToResponse(
            Skill skill
    ) {

        SkillResponse response = new SkillResponse();

        response.setId(skill.getId());
        response.setSkillName(skill.getSkillName());
        response.setProficiency(skill.getProficiency());
        response.setCreatedAt(skill.getCreatedAt());
        response.setUpdatedAt(skill.getUpdatedAt());

        return response;
    }
}