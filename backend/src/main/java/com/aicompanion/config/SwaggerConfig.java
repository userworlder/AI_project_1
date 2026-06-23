package com.aicompanion.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("AI 伴学平台 API")
                        .version("1.0.0")
                        .description("AI 伴学平台后端接口文档")
                        .contact(new Contact()
                                .name("AI Companion")
                                .email("support@aicompanion.com")));
    }
}
