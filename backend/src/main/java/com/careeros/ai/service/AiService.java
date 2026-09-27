package com.careeros.ai.service;

import com.careeros.ai.dto.CareerCoachRequest;
import com.careeros.ai.dto.CareerCoachResponse;
import com.careeros.ai.dto.GeminiSalaryEstimateRequest;
import com.careeros.ai.dto.GeminiSalaryEstimateResponse;
import com.careeros.experience.entity.Experience;
import com.careeros.skill.entity.Skill;
import com.careeros.user.entity.UserProfile;

import java.util.List;

public interface AiService {

    String generateResponse(String prompt);

    GeminiSalaryEstimateResponse estimateSalary(
            GeminiSalaryEstimateRequest request
    );

    CareerCoachResponse careerCoach(
            CareerCoachRequest request,
            UserProfile profile,
            List<Skill> skills,
            List<Experience> experiences
    );
}