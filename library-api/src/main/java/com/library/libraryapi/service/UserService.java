package com.library.libraryapi.service;

import com.library.libraryapi.dto.auth.LoginRequest;
import com.library.libraryapi.dto.auth.RegisterRequest;
import com.library.libraryapi.exception.ConflictException;
import com.library.libraryapi.exception.ResourceNotFoundException;
import com.library.libraryapi.messages.GenericErrorMessages;
import com.library.libraryapi.model.User;
import com.library.libraryapi.repository.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public User register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new ConflictException(GenericErrorMessages.USERNAME_ALREADY_EXISTS_EXCEPTION_MESSAGE);
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new ConflictException(GenericErrorMessages.EMAIL_ALREADY_EXISTS_EXCEPTION_MESSAGE);
        }

        User user = new User();
        user.setUsername(request.username());
        user.setEmail(request.email());
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setRole(User.Role.USER);

        return userRepository.save(user);
    }

    @Transactional(readOnly = true)
    public User authenticate(LoginRequest request) {
        User user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new BadCredentialsException(
                        GenericErrorMessages.INVALID_CREDENTIALS_EXCEPTION_MESSAGE));

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new BadCredentialsException(GenericErrorMessages.INVALID_CREDENTIALS_EXCEPTION_MESSAGE);
        }
        return user;
    }

    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Transactional(readOnly = true)
    public User getByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException(
                        String.format(GenericErrorMessages.USER_NOT_FOUND_EXCEPTION_MESSAGE, username)));
    }

    @Transactional(readOnly = true)
    public List<User> findAll() {
        return userRepository.findAll();
    }
}
