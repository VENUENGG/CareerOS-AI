package com.careeros.ai.controller;

import com.careeros.ai.dto.CareerCoachRequest;
import com.careeros.ai.dto.CareerCoachResponse;
import com.careeros.ai.service.AiService;
import com.careeros.experience.entity.Experience;
import com.careeros.experience.repository.ExperienceRepository;
import com.careeros.security.service.AuthenticatedUserService;
import com.careeros.skill.entity.Skill;
import com.careeros.skill.repository.SkillRepository;
import com.careeros.user.entity.User;
import com.careeros.user.entity.UserProfile;
import com.careeros.user.repository.UserProfileRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/ai")
public class AiController {

    private final AiService aiService;
    private final AuthenticatedUserService authenticatedUserService;
    private final UserProfileRepository userProfileRepository;
    private final SkillRepository skillRepository;
    private final ExperienceRepository experienceRepository;

    public AiController(
            AiService aiService,
            AuthenticatedUserService authenticatedUserService,
            UserProfileRepository userProfileRepository,
            SkillRepository skillRepository,
            ExperienceRepository experienceRepository
    ) {
        this.aiService = aiService;
        this.authenticatedUserService =
                authenticatedUserService;
        this.userProfileRepository =
                userProfileRepository;
        this.skillRepository =
                skillRepository;
        this.experienceRepository =
                experienceRepository;
    }

    @PostMapping("/generate")
    public ResponseEntity<String> generateResponse(
            @Valid @RequestBody AiRequest request
    ) {

        return ResponseEntity.ok(
                aiService.generateResponse(
                        request.prompt()
                )
        );
    }

    @PostMapping("/career-coach")
    public ResponseEntity<CareerCoachResponse> careerCoach(
            @Valid @RequestBody CareerCoachRequest request
    ) {

        User currentUser =
                authenticatedUserService.getCurrentUser();

        UserProfile profile =
                userProfileRepository
                        .findByUser(currentUser)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "User profile not found."
                                )
                        );

        List<Skill> skills =
                skillRepository.findAllByUserProfile(
                        profile
                );

        List<Experience> experiences =
                experienceRepository.findAllByUserProfile(
                        profile
                );

        CareerCoachResponse response =
                aiService.careerCoach(
                        request,
                        profile,
                        skills,
                        experiences
                );

        return ResponseEntity.ok(
                response
        );
    }

    public record AiRequest(
            String prompt
    ) {
    }
}