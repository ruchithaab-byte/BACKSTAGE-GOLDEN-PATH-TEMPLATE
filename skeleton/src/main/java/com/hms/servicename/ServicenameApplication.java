package com.hms.servicename;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@ComponentScan(basePackages = {"com.hms.servicename", "com.hms.lib.common"})
@EnableJpaAuditing(auditorAwareRef = "auditorAwareImpl")
@org.springframework.retry.annotation.EnableRetry
@org.springframework.scheduling.annotation.EnableAsync
public class ServicenameApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServicenameApplication.class, args);
    }
}

