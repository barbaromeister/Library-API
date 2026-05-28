package com.library.libraryapi.controller;

import com.library.libraryapi.dto.auth.AuthResponse;
import com.library.libraryapi.dto.auth.LoginRequest;
import com.library.libraryapi.dto.auth.RegisterRequest;
import com.library.libraryapi.dto.auth.UserResponse;
import com.library.libraryapi.model.User;
import com.library.libraryapi.service.JwtService;
import com.library.libraryapi.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final JwtService jwtService;

    public AuthController(UserService userService, JwtService jwtService) {
        this.userService = userService;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        User user = userService.register(request);
        String token = jwtService.generate(user.getUsername(), user.getRole().name());
        return AuthResponse.of(token, user);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        User user = userService.authenticate(request);
        String token = jwtService.generate(user.getUsername(), user.getRole().name());
        return AuthResponse.of(token, user);
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout() {
        // Stateless JWT — client deletes its token. Token blacklisting not implemented.
    }

    @GetMapping("/me")
    public UserResponse me(Authentication authentication) {
        User user = userService.getByUsername(authentication.getName());
        return UserResponse.from(user);
    }
}
