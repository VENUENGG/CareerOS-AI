package com.careeros.pdf.service.impl;

import com.careeros.pdf.service.PdfService;
import com.careeros.template.service.TemplateService;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;

@Service
public class PdfServiceImpl implements PdfService {

    private final TemplateService templateService;

    public PdfServiceImpl(
            TemplateService templateService
    ) {
        this.templateService = templateService;
    }

    @Override
    public byte[] generateResumePdf(Long resumeId) {

        String html = templateService.generateResumeHtml(resumeId);

        System.out.println("========== PDF DEBUG ==========");
        System.out.println("Resume ID: " + resumeId);
        System.out.println(
                "HTML generated: "
                        + (html != null && !html.isBlank())
        );
        System.out.println(
                "HTML length: "
                        + (html != null ? html.length() : 0)
        );
        System.out.println("===============================");

        if (html == null || html.isBlank()) {
            throw new RuntimeException(
                    "Resume HTML generation returned empty HTML."
            );
        }

        try {

            /*
             * ============================================================
             * LOAD PDF CSS
             * ============================================================
             */

            ClassPathResource cssResource =
                    new ClassPathResource(
                            "static/css/resume-pdf.css"
                    );

            if (!cssResource.exists()) {
                throw new RuntimeException(
                        "PDF stylesheet not found: "
                                + "src/main/resources/static/css/resume-pdf.css"
                );
            }

            String css;

            try (var inputStream = cssResource.getInputStream()) {

                css = new String(
                        inputStream.readAllBytes(),
                        StandardCharsets.UTF_8
                );
            }

            if (css.isBlank()) {
                throw new RuntimeException(
                        "resume-pdf.css exists but is empty."
                );
            }

            System.out.println(
                    "========== PDF CSS DEBUG =========="
            );
            System.out.println("CSS loaded successfully");
            System.out.println("CSS length: " + css.length());
            System.out.println("===================================");


            /*
             * ============================================================
             * REMOVE EXTERNAL CSS REFERENCES
             * ============================================================
             *
             * OpenHTMLToPDF should NOT request our CSS through:
             *
             * http://localhost:8080/css/...
             *
             * The CSS is injected directly below.
             */

            html = html.replaceAll(
                    "(?is)<link\\s+[^>]*href\\s*=\\s*[\"']"
                            + "/css/resume\\.css"
                            + "[\"'][^>]*\\/?>",
                    ""
            );

            html = html.replaceAll(
                    "(?is)<link\\s+[^>]*href\\s*=\\s*[\"']"
                            + "/css/resume-pdf\\.css"
                            + "[\"'][^>]*\\/?>",
                    ""
            );


            /*
             * ============================================================
             * INJECT PDF CSS DIRECTLY
             * ============================================================
             */

            String styleTag =
                    "\n<style type=\"text/css\">\n"
                            + css
                            + "\n</style>\n";


            /*
             * ============================================================
             * MAKE SURE WE HAVE A PROPER HTML DOCUMENT
             * ============================================================
             */

            if (html.contains("</head>")) {

                html = html.replace(
                        "</head>",
                        styleTag + "</head>"
                );

            } else {

                html =
                        "<!DOCTYPE html>"
                                + "<html>"
                                + "<head>"
                                + "<meta charset=\"UTF-8\" />"
                                + styleTag
                                + "</head>"
                                + "<body>"
                                + html
                                + "</body>"
                                + "</html>";
            }


            /*
             * ============================================================
             * FINAL HTML DEBUG
             * ============================================================
             */

            System.out.println(
                    "========== FINAL HTML DEBUG =========="
            );

            System.out.println(
                    "External resume.css removed: "
                            + !html.contains(
                            "/css/resume.css"
                    )
            );

            System.out.println(
                    "External resume-pdf.css removed: "
                            + !html.contains(
                            "/css/resume-pdf.css"
                    )
            );

            System.out.println(
                    "PDF CSS injected: "
                            + html.contains(
                            "<style type=\"text/css\">"
                    )
            );

            System.out.println(
                    "Final HTML length: "
                            + html.length()
            );

            System.out.println(
                    "======================================"
            );


            /*
             * ============================================================
             * GENERATE PDF
             * ============================================================
             */

            try (
                    ByteArrayOutputStream outputStream =
                            new ByteArrayOutputStream()
            ) {

                PdfRendererBuilder builder =
                        new PdfRendererBuilder();

                builder
                        .useFastMode()
                        .withHtmlContent(
                                html,
                                "http://localhost:8080/"
                        )
                        .toStream(outputStream);

                builder.run();

                byte[] pdf =
                        outputStream.toByteArray();


                /*
                 * ========================================================
                 * PDF RESULT
                 * ========================================================
                 */

                System.out.println(
                        "========== PDF RESULT =========="
                );

                System.out.println(
                        "PDF generated successfully"
                );

                System.out.println(
                        "PDF size: "
                                + pdf.length
                                + " bytes"
                );

                System.out.println(
                        "================================"
                );

                return pdf;
            }

        } catch (Exception exception) {

            System.out.println(
                    "========== PDF ERROR =========="
            );

            System.out.println(
                    "Exception: "
                            + exception.getClass().getName()
            );

            System.out.println(
                    "Message: "
                            + exception.getMessage()
            );

            exception.printStackTrace();

            System.out.println(
                    "==============================="
            );

            throw new RuntimeException(
                    "Failed to generate resume PDF.",
                    exception
            );
        }
    }
}