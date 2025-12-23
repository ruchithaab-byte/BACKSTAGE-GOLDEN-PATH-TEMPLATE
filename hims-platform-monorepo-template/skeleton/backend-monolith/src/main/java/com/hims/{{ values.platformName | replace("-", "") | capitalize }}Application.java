package com.hims;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.modulith.Modulith;

/**
 * {{ values.platformName | title }} Platform - Backend Monolith
 * 
 * This is a modular monolith built with Spring Modulith.
 * Core kernel provides tenant isolation, auth, audit, and event infrastructure.
 */
@Modulith
@SpringBootApplication
public class PlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlatformApplication.class, args);
    }
}

