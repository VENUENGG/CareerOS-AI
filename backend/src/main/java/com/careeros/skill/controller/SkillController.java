package com.careeros.skill.controller;

import com.careeros.skill.dto.SkillRequest;
import com.careeros.skill.dto.SkillResponse;
import com.careeros.skill.service.SkillService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/skills")
public class SkillController {

    private final SkillService skillService;

    public SkillController(
            SkillService skillService
    ) {
        this.skillService = skillService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SkillResponse createSkill(
            @Valid @RequestBody SkillRequest request
    ) {
        return skillService.createSkill(request);
    }

    @GetMapping
    public List<SkillResponse> getMySkills() {
        return skillService.getMySkills();
    }

    @GetMapping("/{id}")
    public SkillResponse getSkillById(
            @PathVariable Long id
    ) {
        return skillService.getSkillById(id);
    }

    @PutMapping("/{id}")
    public SkillResponse updateSkill(
            @PathVariable Long id,
            @Valid @RequestBody SkillRequest request
    ) {
        return skillService.updateSkill(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteSkill(
            @PathVariable Long id
    ) {
        skillService.deleteSkill(id);
    }
}