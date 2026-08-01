package com.careeros.exception;

public class SkillNotFoundException extends RuntimeException {

    public SkillNotFoundException(String message) {
        super(message);
    }
}