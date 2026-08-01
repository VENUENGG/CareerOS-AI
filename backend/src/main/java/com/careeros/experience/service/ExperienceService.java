package com.careeros.experience.service;

import com.careeros.experience.dto.ExperienceRequest;
import com.careeros.experience.dto.ExperienceResponse;

import java.util.List;

public interface ExperienceService {

    ExperienceResponse createExperience(
            ExperienceRequest request
    );

    List<ExperienceResponse> getMyExperiences();

    ExperienceResponse getExperienceById(Long id);

    ExperienceResponse updateExperience(
            Long id,
            ExperienceRequest request
    );

    void deleteExperience(Long id);
}