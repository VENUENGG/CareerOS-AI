package com.careeros.user.controller;

import com.careeros.common.constants.MessageConstants;
import com.careeros.common.response.ApiResponse;
import com.careeros.user.dto.LoginRequest;
import com.careeros.user.dto.LoginResponse;
import com.careeros.user.dto.RegisterRequest;
import com.careeros.user.dto.RegisterResponse;
import com.careeros.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<RegisterResponse>> register(
            @Valid @RequestBody RegisterRequest request
    ) {

        RegisterResponse response = userService.register(request);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        true,
                        MessageConstants.USER_REGISTERED_SUCCESSFULLY,
                        response
                ));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(
            @Valid @RequestBody LoginRequest request
    ) {

        LoginResponse response = userService.login(request);

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        MessageConstants.LOGIN_SUCCESSFUL,
                        response
                )
        );
    }
}