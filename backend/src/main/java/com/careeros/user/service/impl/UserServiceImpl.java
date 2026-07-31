package com.careeros.user.service.impl;

import com.careeros.common.constants.MessageConstants;
import com.careeros.exception.EmailAlreadyExistsException;
import com.careeros.security.jwt.JwtService;
import com.careeros.user.dto.LoginRequest;
import com.careeros.user.dto.LoginResponse;
import com.careeros.user.dto.RegisterRequest;
import com.careeros.user.dto.RegisterResponse;
import com.careeros.user.entity.User;
import com.careeros.user.repository.UserRepository;
import com.careeros.user.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    private static final Logger logger =
            LoggerFactory.getLogger(UserServiceImpl.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public UserServiceImpl(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Override
    public RegisterResponse register(RegisterRequest request) {

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new EmailAlreadyExistsException("Email already exists.");
        }

        User user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User savedUser = userRepository.save(user);

        logger.info("New user registered: {}", savedUser.getEmail());

        RegisterResponse response = new RegisterResponse();
        response.setUserId(savedUser.getId());
        response.setMessage(MessageConstants.USER_REGISTERED_SUCCESSFULLY);

        return response;
    }

    @Override
    public LoginResponse login(LoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() ->
                        new RuntimeException("Invalid email or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid email or password");
        }

        String accessToken = jwtService.generateAccessToken(user.getEmail());

        logger.info("User logged in: {}", user.getEmail());

        LoginResponse response = new LoginResponse();
        response.setUserId(user.getId());
        response.setAccessToken(accessToken);
        response.setMessage(MessageConstants.LOGIN_SUCCESSFUL);

        return response;
    }
}