package com.kutuphane.libraryapi.controller;

import com.kutuphane.libraryapi.model.User;
import com.kutuphane.libraryapi.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.util.Collections;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody RegisterRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            User user = userService.registerUser(request.getUsername(), request.getEmail(), request.getPassword());
            response.put("success", true);
            response.put("message", "User registered successfully");
            response.put("username", user.getUsername());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginRequest request, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        boolean isAuthenticated = userService.authenticateUser(request.getUsername(), request.getPassword());
        
        if (isAuthenticated) {
            Optional<User> userOptional = userService.findByUsername(request.getUsername());
            if (userOptional.isPresent()) {
                User user = userOptional.get();
                
                // Set session attributes
                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole().toString());
                
                // Set Spring Security context
                Authentication authentication = new UsernamePasswordAuthenticationToken(
                    user.getUsername(),
                    null,
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
                );
                SecurityContextHolder.getContext().setAuthentication(authentication);
                
                response.put("success", true);
                response.put("message", "Login successful");
                response.put("username", user.getUsername());
                response.put("role", user.getRole().toString());
                return ResponseEntity.ok(response);
            }
        }
        
        response.put("success", false);
        response.put("message", "Invalid username or password");
        return ResponseEntity.badRequest().body(response);
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Map<String, Object>> logout(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        session.invalidate();
        response.put("success", true);
        response.put("message", "Logout successful");
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        // Check both session and security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = (String) session.getAttribute("username");
        
        if (username != null && authentication != null && authentication.isAuthenticated() 
            && !authentication.getName().equals("anonymousUser")) {
            response.put("success", true);
            response.put("username", username);
            response.put("role", session.getAttribute("role"));
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Not authenticated");
            return ResponseEntity.status(401).body(response);
        }
    }
    
    public static class RegisterRequest {
        private String username;
        private String email;
        private String password;
        
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
    
    public static class LoginRequest {
        private String username;
        private String password;
        
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
}