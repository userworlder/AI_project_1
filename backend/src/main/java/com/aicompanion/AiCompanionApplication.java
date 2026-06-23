package com.aicompanion;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.aicompanion.mapper")
public class AiCompanionApplication {
    public static void main(String[] args) {
        SpringApplication.run(AiCompanionApplication.class, args);
    }
}
