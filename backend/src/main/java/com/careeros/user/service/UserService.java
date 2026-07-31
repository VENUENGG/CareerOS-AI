package com.careeros.user.service;

import com.careeros.user.dto.LoginRequest;
import com.careeros.user.dto.LoginResponse;
import com.careeros.user.dto.RegisterRequest;
import com.careeros.user.dto.RegisterResponse;

public interface UserService {

    RegisterResponse register(RegisterRequest request);

    LoginResponse login(LoginRequest request);
}