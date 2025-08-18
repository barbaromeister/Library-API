package com.kutuphane.libraryapi.controller;

import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

@RestController
@RequestMapping("/api/test")
public class TestController {
    
    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Application is running");
        return response;
    }
    
    @PostMapping("/echo")
    public Map<String, Object> echo(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        response.put("received", request);
        response.put("timestamp", System.currentTimeMillis());
        return response;
    }
    
    @GetMapping("/admin/users")
    public List<Map<String, Object>> getAllUsers() {
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