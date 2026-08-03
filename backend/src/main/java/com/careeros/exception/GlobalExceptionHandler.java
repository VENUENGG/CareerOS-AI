package com.careeros.exception;

import com.careeros.exception.SocialLinksAlreadyExistsException;
import com.careeros.exception.SocialLinksNotFoundException;
import com.careeros.exception.LanguageNotFoundException;
import com.careeros.exception.CertificationNotFoundException;
import com.careeros.exception.ProjectNotFoundException;
import com.careeros.exception.SkillNotFoundException;
import com.careeros.common.response.ApiErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EmailAlreadyExistsException.class)
    public ResponseEntity<ApiErrorResponse> handleEmailAlreadyExists(
            EmailAlreadyExistsException ex
    ) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.CONFLICT.value(),
                        ex.getMessage()
                ));
    }

    @ExceptionHandler(ProfileAlreadyExistsException.class)
    public ResponseEntity<ApiErrorResponse> handleProfileAlreadyExists(
            ProfileAlreadyExistsException ex
    ) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.CONFLICT.value(),
                        ex.getMessage()
                ));
    }

    @ExceptionHandler(ProfileNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleProfileNotFound(
            ProfileNotFoundException ex
    ) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.NOT_FOUND.value(),
                        ex.getMessage()
                ));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiErrorResponse> handleRuntimeException(
            RuntimeException ex
    ) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.BAD_REQUEST.value(),
                        ex.getMessage()
                ));
    }@ExceptionHandler(UserProfileNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleUserProfileNotFound(
            UserProfileNotFoundException ex
    ) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.NOT_FOUND.value(),
                        ex.getMessage()
                ));
    }

    @ExceptionHandler(EducationNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleEducationNotFound(
            EducationNotFoundException ex
    ) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ApiErrorResponse(
                        false,
                        HttpStatus.NOT_FOUND.value(),
                        ex.getMessage()
                ));
    }
    @ExceptionHandler(ExperienceNotFoundException.class)
    public ResponseEntity<String> handleExperienceNotFound(
            ExperienceNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
    @ExceptionHandler(SkillNotFoundException.class)
    public ResponseEntity<String> handleSkillNotFound(
            SkillNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
    @ExceptionHandler(ProjectNotFoundException.class)
    public ResponseEntity<String> handleProjectNotFound(
            ProjectNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
    @ExceptionHandler(CertificationNotFoundException.class)
    public ResponseEntity<String> handleCertificationNotFound(
            CertificationNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
    @ExceptionHandler(LanguageNotFoundException.class)
    public ResponseEntity<String> handleLanguageNotFound(
            LanguageNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }
    @ExceptionHandler(SocialLinksNotFoundException.class)
    public ResponseEntity<String> handleSocialLinksNotFound(
            SocialLinksNotFoundException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ex.getMessage());
    }

    @ExceptionHandler(SocialLinksAlreadyExistsException.class)
    public ResponseEntity<String> handleSocialLinksAlreadyExists(
            SocialLinksAlreadyExistsException ex
    ) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ex.getMessage());
    }
}