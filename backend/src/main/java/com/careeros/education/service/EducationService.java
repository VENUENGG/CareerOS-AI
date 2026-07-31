package com.careeros.education.service;

import com.careeros.education.dto.EducationRequest;
import com.careeros.education.dto.EducationResponse;

import java.util.List;

public interface EducationService {

    EducationResponse createEducation(EducationRequest request);

    List<EducationResponse> getMyEducations();

    EducationResponse getEducationById(Long id);

    EducationResponse updateEducation(Long id, EducationRequest request);

    void deleteEducation(Long id);
}