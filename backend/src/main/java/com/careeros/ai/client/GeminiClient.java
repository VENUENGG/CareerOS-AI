package com.careeros.ai.client;

import com.careeros.exception.GeminiServiceException;
import com.google.genai.Client;
import com.google.genai.types.GenerateContentConfig;
import com.google.genai.types.GenerateContentResponse;
import com.google.genai.types.GoogleSearch;
import com.google.genai.types.Tool;
import org.springframework.stereotype.Component;

@Component
public class GeminiClient {

    private static final String MODEL = "gemini-3.6-flash";

    private final Client client;

    public GeminiClient(Client client) {
        this.client = client;
    }

    public String generateText(String prompt) {

        validatePrompt(prompt);

        try {

            GenerateContentResponse response =
                    client.models.generateContent(
                            MODEL,
                            prompt,
                            null
                    );

            return extractResponseText(
                    response,
                    false
            );

        } catch (RuntimeException exception) {

            throw convertGeminiException(
                    exception,
                    false
            );
        }
    }

    public String generateGroundedJson(String prompt) {

        validatePrompt(prompt);

        Tool googleSearchTool =
                Tool.builder()
                        .googleSearch(
                                GoogleSearch.builder().build()
                        )
                        .build();

        GenerateContentConfig config =
                GenerateContentConfig.builder()
                        .tools(googleSearchTool)
                        .responseMimeType("application/json")
                        .candidateCount(1)
                        .build();

        try {

            GenerateContentResponse response =
                    client.models.generateContent(
                            MODEL,
                            prompt,
                            config
                    );

            return extractResponseText(
                    response,
                    true
            );

        } catch (RuntimeException exception) {

            throw convertGeminiException(
                    exception,
                    true
            );
        }
    }

    private void validatePrompt(
            String prompt
    ) {

        if (prompt == null || prompt.isBlank()) {

            throw new IllegalArgumentException(
                    "Gemini prompt must not be null or empty."
            );
        }
    }

    private String extractResponseText(
            GenerateContentResponse response,
            boolean grounded
    ) {

        if (response == null) {

            throw new GeminiServiceException(
                    grounded
                            ? "Gemini returned no grounded response."
                            : "Gemini returned no response."
            );
        }

        String text =
                response.text();

        if (text == null || text.isBlank()) {

            throw new GeminiServiceException(
                    grounded
                            ? "Gemini returned an empty grounded response."
                            : "Gemini returned an empty response."
            );
        }

        return text.trim();
    }

    private GeminiServiceException
    convertGeminiException(
            RuntimeException exception,
            boolean grounded
    ) {

        String message =
                exception.getMessage();

        String normalizedMessage =
                message == null
                        ? ""
                        : message.toLowerCase();

        /*
         * Rate limit / quota exhaustion.
         */
        if (normalizedMessage.contains("429")
                || normalizedMessage.contains("resource exhausted")
                || normalizedMessage.contains("quota exceeded")
                || normalizedMessage.contains("rate limit")) {

            return new GeminiServiceException(
                    "Gemini AI quota has been reached. "
                            + "Please try again later.",
                    exception
            );
        }

        /*
         * Authentication / API-key problems.
         */
        if (normalizedMessage.contains("401")
                || normalizedMessage.contains("403")
                || normalizedMessage.contains("api key")
                || normalizedMessage.contains("authentication")) {

            return new GeminiServiceException(
                    "Gemini AI authentication failed. "
                            + "Please verify the configured API key.",
                    exception
            );
        }

        /*
         * Temporary Google/API availability problems.
         */
        if (normalizedMessage.contains("500")
                || normalizedMessage.contains("502")
                || normalizedMessage.contains("503")
                || normalizedMessage.contains("504")
                || normalizedMessage.contains("timeout")
                || normalizedMessage.contains("timed out")) {

            return new GeminiServiceException(
                    "Gemini AI is temporarily unavailable. "
                            + "Please try again later.",
                    exception
            );
        }

        return new GeminiServiceException(
                grounded
                        ? "Gemini grounded AI request failed."
                        : "Gemini AI request failed.",
                exception
        );
    }
}