package com.kutuphane.libraryapi.controller;

import com.kutuphane.libraryapi.model.User;
import com.kutuphane.libraryapi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/setup")
public class SetupController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @PostMapping("/create-admin")
    public Map<String, Object> createAdmin() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Check if admin already exists
            if (userRepository.existsByUsername("admin")) {
                // Update existing admin password
                User existingAdmin = userRepository.findByUsername("admin").orElse(null);
                if (existingAdmin != null) {
                    existingAdmin.setPassword(passwordEncoder.encode("admin"));
                    existingAdmin.setRole(User.Role.ADMIN);
                    userRepository.save(existingAdmin);
                    response.put("success", true);
                    response.put("message", "Admin password updated successfully");
                }
            } else {
                // Create new admin user
                User admin = new User();
                admin.setUsername("admin");
                admin.setEmail("admin@library.com");
                admin.setPassword(passwordEncoder.encode("admin"));
                admin.setRole(User.Role.ADMIN);
                
                userRepository.save(admin);
                response.put("success", true);
                response.put("message", "Admin user created successfully");
            }
            
            response.put("username", "admin");
            response.put("password", "admin");
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to create admin: " + e.getMessage());
        }
        
        return response;
    }
    
    @GetMapping("/test-password")
    public Map<String, Object> testPassword(@RequestParam String password) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            User admin = userRepository.findByUsername("admin").orElse(null);
            if (admin != null) {
                boolean matches = passwordEncoder.matches(password, admin.getPassword());
                response.put("success", true);
                response.put("password_matches", matches);
                response.put("stored_hash_preview", admin.getPassword().substring(0, Math.min(20, admin.getPassword().length())));
            } else {
                response.put("success", false);
                response.put("message", "Admin user not found");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        
        return response;
    }
}