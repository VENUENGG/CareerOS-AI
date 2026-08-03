package com.careeros.resume.service;

import com.careeros.resume.dto.ResumeRequest;
import com.careeros.resume.dto.ResumeResponse;

import java.util.List;

public interface ResumeService {

    ResumeResponse createResume(
            ResumeRequest request
    );

    List<ResumeResponse> getMyResumes();

    ResumeResponse getResumeById(
            Long id
    );

    ResumeResponse updateResume(
            Long id,
            ResumeRequest request
    );

    void deleteResume(
            Long id
    );
}