package com.hims;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.modulith.Modulith;

/**
 * {{ values.platformName | title }} Platform - Backend Monolith
 * 
 * This is a modular monolith built with Spring Modulith.
 * Modules are isolated by package structure and enforced by ArchUnit.
 */
@Modulith
@SpringBootApplication
public class {{ values.platformName | replace("-", "") | capitalize }}Application {

    public static void main(String[] args) {
        SpringApplication.run({{ values.platformName | replace("-", "") | capitalize }}Application.class, args);
    }
}

