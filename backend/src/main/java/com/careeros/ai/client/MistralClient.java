package com.careeros.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Component
public class MistralClient {

    private static final String MODEL =
            "mistral-small-latest";

    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public MistralClient(
            @Qualifier("mistralRestClient") RestClient restClient,
            ObjectMapper objectMapper
    ) {
        this.restClient = restClient;
        this.objectMapper = objectMapper;
    }

    public String generateText(String prompt) {

        validatePrompt(prompt);

        Map<String, Object> requestBody =
                Map.of(
                        "model", MODEL,
                        "messages", List.of(
                                Map.of(
                                        "role", "user",
                                        "content", prompt
                                )
                        ),
                        "temperature", 0.7
                );

        try {

            String response =
                    restClient.post()
                            .uri("/chat/completions")
                            .contentType(MediaType.APPLICATION_JSON)
                            .body(requestBody)
                            .retrieve()
                            .body(String.class);

            return extractText(response);

        } catch (RuntimeException exception) {

            throw new IllegalStateException(
                    "Mistral AI request failed.",
                    exception
            );
        }
    }

    public String generateJson(String prompt) {

        validatePrompt(prompt);

        Map<String, Object> requestBody =
                Map.of(
                        "model", MODEL,
                        "messages", List.of(
                                Map.of(
                                        "role", "system",
                                        "content",
                                        "Return only valid JSON."
                                ),
                                Map.of(
                                        "role", "user",
                                        "content", prompt
                                )
                        ),
                        "temperature", 0.2
                );

        try {

            String response =
                    restClient.post()
                            .uri("/chat/completions")
                            .contentType(MediaType.APPLICATION_JSON)
                            .body(requestBody)
                            .retrieve()
                            .body(String.class);

            return extractText(response);

        } catch (RuntimeException exception) {

            throw new IllegalStateException(
                    "Mistral JSON AI request failed.",
                    exception
            );
        }
    }

    private String extractText(String response) {

        if (response == null || response.isBlank()) {
            throw new IllegalStateException(
                    "Mistral returned an empty response."
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
                        "Mistral returned an empty AI response."
                );
            }

            return content.asText().trim();

        } catch (Exception exception) {

            throw new IllegalStateException(
                    "Failed to parse Mistral response.",
                    exception
            );
        }
    }

    private void validatePrompt(String prompt) {

        if (prompt == null || prompt.isBlank()) {
            throw new IllegalArgumentException(
                    "Mistral prompt must not be null or empty."
            );
        }
    }
}