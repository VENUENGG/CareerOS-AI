package com.careeros.ai.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CareerCoachRequest {

    @NotBlank(message = "Career goal is required.")
    @Size(
            min = 5,
            max = 500,
            message = "Career goal must be between 5 and 500 characters."
    )
    private String goal;
}