package com.simple_timeservice.simple_timeservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.Map;

@SpringBootApplication
@RestController
public class SimpleTimeserviceApplication {

  public static void main(String[] args) {
    SpringApplication.run(SimpleTimeserviceApplication.class, args);
  }

@GetMapping("/")
public Map<String, String> home(HttpServletRequest request) {

    String forwardedFor = request.getHeader("X-Forwarded-For");
    String ip;

    if (forwardedFor != null && !forwardedFor.isBlank()) {
        ip = forwardedFor.split(",")[0].trim();
    } else {
        ip = request.getRemoteAddr();
    }

    return Map.of(
        "timestamp", Instant.now().toString(),
        "ip", ip
    );
  }
}
