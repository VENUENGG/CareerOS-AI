package com.careeros.template.controller;

import com.careeros.template.service.TemplateService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/templates")
public class TemplateController {

    private final TemplateService templateService;

    public TemplateController(
            TemplateService templateService
    ) {
        this.templateService = templateService;
    }

    @GetMapping(
            value = "/resumes/{resumeId}",
            produces = MediaType.TEXT_HTML_VALUE
    )
    public String generateResume(
            @PathVariable Long resumeId
    ) {

        return templateService.generateResumeHtml(
                resumeId
        );
    }
}