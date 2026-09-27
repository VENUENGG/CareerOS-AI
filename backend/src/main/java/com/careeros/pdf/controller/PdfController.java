package com.careeros.pdf.controller;

import com.careeros.pdf.service.PdfService;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/resumes")
public class PdfController {

    private final PdfService pdfService;

    public PdfController(
            PdfService pdfService
    ) {
        this.pdfService = pdfService;
    }

    @GetMapping("/{resumeId}/pdf")
    public ResponseEntity<byte[]> generateResumePdf(
            @PathVariable Long resumeId
    ) {

        byte[] pdf =
                pdfService.generateResumePdf(resumeId);

        HttpHeaders headers =
                new HttpHeaders();

        headers.setContentType(
                MediaType.APPLICATION_PDF
        );

        headers.setContentDisposition(
                ContentDisposition
                        .attachment()
                        .filename(
                                "Java-Backend-Resume.pdf"
                        )
                        .build()
        );

        headers.setContentLength(pdf.length);

        return ResponseEntity
                .ok()
                .headers(headers)
                .body(pdf);
    }
}