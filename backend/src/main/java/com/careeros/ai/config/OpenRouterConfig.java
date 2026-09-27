package com.careeros.ai.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class OpenRouterConfig {

    @Bean(name = "openRouterRestClient")
    public RestClient openRouterRestClient(
            @Value("${openrouter.api-key}") String apiKey
    ) {

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException(
                    "OPENROUTER_API_KEY environment variable is not configured."
            );
        }

        return RestClient.builder()
                .baseUrl("https://openrouter.ai/api/v1")
                .defaultHeader(
                        "Authorization",
                        "Bearer " + apiKey
                )
                .defaultHeader(
                        "Content-Type",
                        "application/json"
                )
                .defaultHeader(
                        "X-Title",
                        "CareerOS AI"
                )
                .build();
    }
}