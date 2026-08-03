package com.careeros.exception;

public class LanguageNotFoundException extends RuntimeException {

    public LanguageNotFoundException(String message) {
        super(message);
    }
}