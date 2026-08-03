package com.careeros.resumeselection.service;

import com.careeros.resumeselection.dto.ResumeSelectionRequest;
import com.careeros.resumeselection.dto.ResumeSelectionResponse;

public interface ResumeSelectionService {

    ResumeSelectionResponse saveSelections(
            Long resumeId,
            ResumeSelectionRequest request
    );

    ResumeSelectionResponse getSelections(
            Long resumeId
    );
}