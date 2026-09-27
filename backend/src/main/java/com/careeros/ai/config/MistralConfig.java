package com.careeros.ai.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class MistralConfig {

    @Bean(name = "mistralRestClient")
    public RestClient mistralRestClient(
            @Value("${mistral.api-key}") String apiKey
    ) {

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException(
                    "MISTRAL_API_KEY environment variable is not configured."
            );
        }

        return RestClient.builder()
                .baseUrl("https://api.mistral.ai/v1")
                .defaultHeader(
                        "Authorization",
                        "Bearer " + apiKey
                )
                .defaultHeader(
                        "Content-Type",
                        "application/json"
                )
                .build();
    }
}