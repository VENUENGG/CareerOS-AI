package com.careeros.salary.ai;

import com.careeros.ai.client.GeminiClient;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Component
public class SalaryAiEstimator {

    private final GeminiClient geminiClient;
    private final ObjectMapper objectMapper;

    public SalaryAiEstimator(
            GeminiClient geminiClient,
            ObjectMapper objectMapper
    ) {
        this.geminiClient = geminiClient;
        this.objectMapper = objectMapper;
    }

    public SalaryAiResult estimate(
            String jobTitle,
            String location,
            String industry,
            int experienceYears,
            List<String> skillNames
    ) {

        String prompt = buildPrompt(
                jobTitle,
                location,
                industry,
                experienceYears,
                skillNames
        );

        String json =
                geminiClient.generateGroundedJson(prompt);

        return parseResponse(json);
    }

    private String buildPrompt(
            String jobTitle,
            String location,
            String industry,
            int experienceYears,
            List<String> skillNames
    ) {

        String skills =
                skillNames == null || skillNames.isEmpty()
                        ? "None provided"
                        : String.join(", ", skillNames);

        return """
                You are the salary research engine for CareerOS AI.

                Estimate the current annual market salary for the requested
                professional profile.

                IMPORTANT:
                - Use Google Search grounding to research current market data.
                - Prefer recent, credible salary sources.
                - Consider the requested location.
                - Consider the industry.
                - Consider the exact job title.
                - Consider years of experience.
                - Consider the user's technical skills.
                - Do NOT invent a fake source.
                - Do NOT return monthly salary.
                - Return annual salary.
                - Currency must match the requested market.
                - For India, use INR.
                - Return realistic market ranges rather than extreme outliers.
                - minimumSalary must be <= expectedSalary.
                - expectedSalary must be <= maximumSalary.
                - Return ONLY valid JSON.
                - Do not wrap JSON in markdown.
                - Do not include explanations outside JSON.

                Candidate profile:

                Job Title: %s
                Location: %s
                Industry: %s
                Experience Years: %d
                Skills: %s

                Required JSON:

                {
                  "minimumSalary": number,
                  "expectedSalary": number,
                  "maximumSalary": number,
                  "currency": "string",
                  "factors": [
                    "string"
                  ]
                }

                Factors should briefly explain the major reasons affecting
                the estimate, such as role demand, experience, location,
                skills, and current market conditions.
                """.formatted(
                jobTitle,
                location,
                industry,
                experienceYears,
                skills
        );
    }

    private SalaryAiResult parseResponse(
            String json
    ) {

        try {

            JsonNode root =
                    objectMapper.readTree(json);

            BigDecimal minimum =
                    readRequiredDecimal(
                            root,
                            "minimumSalary"
                    );

            BigDecimal expected =
                    readRequiredDecimal(
                            root,
                            "expectedSalary"
                    );

            BigDecimal maximum =
                    readRequiredDecimal(
                            root,
                            "maximumSalary"
                    );

            String currency =
                    root.path("currency")
                            .asText(null);

            if (currency == null || currency.isBlank()) {
                throw new IllegalStateException(
                        "Gemini did not return a salary currency."
                );
            }

            List<String> factors =
                    new ArrayList<>();

            JsonNode factorsNode =
                    root.path("factors");

            if (factorsNode.isArray()) {

                for (JsonNode factor : factorsNode) {

                    if (!factor.asText().isBlank()) {
                        factors.add(
                                factor.asText()
                        );
                    }
                }
            }

            minimum =
                    minimum.setScale(
                            0,
                            RoundingMode.HALF_UP
                    );

            expected =
                    expected.setScale(
                            0,
                            RoundingMode.HALF_UP
                    );

            maximum =
                    maximum.setScale(
                            0,
                            RoundingMode.HALF_UP
                    );

            if (minimum.compareTo(BigDecimal.ZERO) <= 0
                    || expected.compareTo(BigDecimal.ZERO) <= 0
                    || maximum.compareTo(BigDecimal.ZERO) <= 0) {

                throw new IllegalStateException(
                        "Gemini returned invalid salary values."
                );
            }

            if (expected.compareTo(minimum) < 0) {
                throw new IllegalStateException(
                        "Gemini returned expected salary below minimum salary."
                );
            }

            if (maximum.compareTo(expected) < 0) {
                throw new IllegalStateException(
                        "Gemini returned maximum salary below expected salary."
                );
            }

            return new SalaryAiResult(
                    minimum,
                    expected,
                    maximum,
                    currency.trim().toUpperCase(),
                    factors
            );

        } catch (Exception exception) {

            throw new IllegalStateException(
                    "Failed to parse Gemini salary estimate.",
                    exception
            );
        }
    }

    private BigDecimal readRequiredDecimal(
            JsonNode root,
            String field
    ) {

        JsonNode node =
                root.get(field);

        if (node == null || !node.isNumber()) {
            throw new IllegalStateException(
                    "Gemini response missing numeric field: "
                            + field
            );
        }

        return node.decimalValue();
    }

    public record SalaryAiResult(
            BigDecimal minimumSalary,
            BigDecimal expectedSalary,
            BigDecimal maximumSalary,
            String currency,
            List<String> factors
    ) {
    }
}