package com.careeros.ats.service;

import com.careeros.ats.dto.AtsAnalysisRequest;
import com.careeros.ats.dto.AtsAnalysisResponse;

import java.util.List;

public interface AtsAnalysisService {

    AtsAnalysisResponse analyzeResume(
            Long resumeId,
            AtsAnalysisRequest request
    );

    AtsAnalysisResponse getLatestAnalysis(
            Long resumeId
    );

    List<AtsAnalysisResponse> getAnalysisHistory(
            Long resumeId
    );
}