package com.careeros.user.controller;

import com.careeros.user.dto.LoginRequest;
import com.careeros.user.dto.LoginResponse;
import com.careeros.user.dto.RegisterRequest;
import com.careeros.user.dto.RegisterResponse;
import com.careeros.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public RegisterResponse register(@Valid @RequestBody RegisterRequest request) {
        return userService.register(request);
    }
    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        return userService.login(request);
    }
}