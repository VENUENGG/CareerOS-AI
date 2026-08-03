package com.careeros.exception;

public class SocialLinksAlreadyExistsException extends RuntimeException {

    public SocialLinksAlreadyExistsException(String message) {
        super(message);
    }
}