package com.careeros.user.service;

import com.careeros.exception.EmailAlreadyExistsException;
import java.util.Optional;
import com.careeros.user.dto.RegisterRequest;
import com.careeros.user.dto.RegisterResponse;
import com.careeros.user.entity.User;
import com.careeros.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public RegisterResponse register(RegisterRequest request) {

        Optional<User> existingUser = userRepository.findByEmail(request.getEmail());

        if (existingUser.isPresent()) {
            throw new EmailAlreadyExistsException("Email already exists");
        }
        User user = new User();

        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User savedUser = userRepository.save(user);

        RegisterResponse response = new RegisterResponse();
        response.setUserId(savedUser.getId());
        response.setMessage("Registration successful");

        return response;
    }
}