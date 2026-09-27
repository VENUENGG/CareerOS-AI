package com.careeros.ai.provider;

import com.careeros.ai.client.CerebrasClient;
import com.careeros.ai.client.GeminiClient;
import com.careeros.ai.client.GroqClient;
import com.careeros.ai.client.MistralClient;
import com.careeros.ai.client.OpenRouterClient;
import org.springframework.stereotype.Component;

@Component
public class AiProviderRouter {

    private final GeminiClient geminiClient;
    private final GroqClient groqClient;
    private final CerebrasClient cerebrasClient;
    private final MistralClient mistralClient;
    private final OpenRouterClient openRouterClient;

    public AiProviderRouter(
            GeminiClient geminiClient,
            GroqClient groqClient,
            CerebrasClient cerebrasClient,
            MistralClient mistralClient,
            OpenRouterClient openRouterClient
    ) {
        this.geminiClient = geminiClient;
        this.groqClient = groqClient;
        this.cerebrasClient = cerebrasClient;
        this.mistralClient = mistralClient;
        this.openRouterClient = openRouterClient;
    }

    public ProviderResponse generateText(
            String prompt
    ) {

        try {
            return new ProviderResponse(
                    "GEMINI",
                    geminiClient.generateText(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "GROQ",
                    groqClient.generateText(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "CEREBRAS",
                    cerebrasClient.generateText(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "MISTRAL",
                    mistralClient.generateText(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "OPENROUTER",
                    openRouterClient.generateText(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        throw new IllegalStateException(
                "All configured AI providers are unavailable."
        );
    }

    public ProviderResponse generateJson(
            String prompt
    ) {

        try {
            return new ProviderResponse(
                    "GEMINI",
                    geminiClient.generateGroundedJson(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "GROQ",
                    groqClient.generateJson(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "CEREBRAS",
                    cerebrasClient.generateJson(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "MISTRAL",
                    mistralClient.generateJson(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        try {
            return new ProviderResponse(
                    "OPENROUTER",
                    openRouterClient.generateJson(prompt)
            );
        } catch (RuntimeException ignored) {
        }

        throw new IllegalStateException(
                "All configured AI providers are unavailable."
        );
    }

    public record ProviderResponse(
            String provider,
            String content
    ) {
    }
}