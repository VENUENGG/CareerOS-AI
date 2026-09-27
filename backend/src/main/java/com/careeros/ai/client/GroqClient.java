package com.careeros.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Component
public class GroqClient {

    private static final String MODEL =
            "llama-3.3-70b-versatile";

    private final RestClient groqRestClient;
    private final ObjectMapper objectMapper;

    public GroqClient(
            RestClient groqRestClient,
            ObjectMapper objectMapper
    ) {
        this.groqRestClient = groqRestClient;
        this.objectMapper = objectMapper;
    }

    public String generateText(
            String prompt
    ) {

        validatePrompt(prompt);

        Map<String, Object> requestBody =
                Map.of(
                        "model",
                        MODEL,
                        "messages",
                        List.of(
                                Map.of(
                                        "role",
                                        "user",
                                        "content",
                                        prompt
                                )
                        ),
                        "temperature",
                        0.7
                );

        try {

            String response =
                    groqRestClient
                            .post()
                            .uri("/chat/completions")
                            .contentType(
                                    MediaType.APPLICATION_JSON
                            )
                            .body(requestBody)
                            .retrieve()
                            .body(String.class);

            return extractText(response);

        } catch (RuntimeException exception) {

            throw new IllegalStateException(
                    "Groq AI request failed.",
                    exception
            );
        }
    }

    public String generateJson(
            String prompt
    ) {

        validatePrompt(prompt);

        Map<String, Object> requestBody =
                Map.of(
                        "model",
                        MODEL,
                        "messages",
                        List.of(
                                Map.of(
                                        "role",
                                        "system",
                                        "content",
                                        "Return only valid JSON."
                                ),
                                Map.of(
                                        "role",
                                        "user",
                                        "content",
                                        prompt
                                )
                        ),
                        "temperature",
                        0.2,
                        "response_format",
                        Map.of(
                                "type",
                                "json_object"
                        )
                );

        try {

            String response =
                    groqRestClient
                            .post()
                            .uri("/chat/completions")
                            .contentType(
                                    MediaType.APPLICATION_JSON
                            )
                            .body(requestBody)
                            .retrieve()
                            .body(String.class);

            return extractText(response);

        } catch (RuntimeException exception) {

            throw new IllegalStateException(
                    "Groq JSON AI request failed.",
                    exception
            );
        }
    }

    private String extractText(
            String response
    ) {

        if (response == null
                || response.isBlank()) {

            throw new IllegalStateException(
                    "Groq returned an empty response."
            );
        }

        try {

            JsonNode root =
                    objectMapper.readTree(response);

            JsonNode content =
                    root.path("choices")
                            .path(0)
                            .path("message")
                            .path("content");

            if (content.isMissingNode()
                    || content.asText().isBlank()) {

                throw new IllegalStateException(
                        "Groq returned an empty AI response."
                );
            }

            return content.asText().trim();

        } catch (Exception exception) {

            throw new IllegalStateException(
                    "Failed to parse Groq response.",
                    exception
            );
        }
    }

    private void validatePrompt(
            String prompt
    ) {

        if (prompt == null || prompt.isBlank()) {

            throw new IllegalArgumentException(
                    "Groq prompt must not be null or empty."
            );
        }
    }
}