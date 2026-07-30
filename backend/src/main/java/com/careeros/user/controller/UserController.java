package com.careeros.user.controller;

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
    public RegisterResponse register(@org.springframework.validation.annotation.Validated @Valid @RequestBody RegisterRequest request) {
        {
            return userService.register(request);
        }
    }}