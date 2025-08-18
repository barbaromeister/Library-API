package com.kutuphane.libraryapi.controller;

import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    
    @GetMapping("/test")
    public Map<String, Object> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Admin controller is working");
        return response;
    }
    
    @GetMapping("/users")
    public List<Map<String, Object>> getAllUsers() {
        // Temporary mock data to test if endpoint works
        List<Map<String, Object>> users = new ArrayList<>();
        
        Map<String, Object> user1 = new HashMap<>();
        user1.put("id", 1);
        user1.put("username", "kaang");
        user1.put("email", "germiyan.kaan@gmail.com");
        user1.put("role", "USER");
        user1.put("createdAt", "2025-08-18T11:55:46");
        users.add(user1);
        
        Map<String, Object> user2 = new HashMap<>();
        user2.put("id", 2);
        user2.put("username", "admin");
        user2.put("email", "admin@library.com");
        user2.put("role", "ADMIN");
        user2.put("createdAt", "2025-08-18T12:00:00");
        users.add(user2);
        
        return users;
    }
}