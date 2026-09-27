package com.careeros.ai.provider;

public interface AiProvider {

    String getName();

    String generateText(String prompt);

    String generateJson(String prompt);
}