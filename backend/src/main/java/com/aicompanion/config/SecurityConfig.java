package com.aicompanion.config;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity   // 启用 @PreAuthorize 等方法级安全注解
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
        // 无状态会话（使用 JWT，不创建 Session）
        .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        // 自动保存 SecurityContext（解决 SSE 流式接口异步分发丢失认证上下文的问题）
        .securityContext(context -> context.requireExplicitSave(false))
        .cors(cors -> cors.configurationSource(request -> {
            var corsConfiguration = new org.springframework.web.cors.CorsConfiguration();
            corsConfiguration.setAllowedOriginPatterns(java.util.List.of("*"));
            corsConfiguration.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
            corsConfiguration.setAllowedHeaders(java.util.List.of("*"));
            corsConfiguration.setExposedHeaders(java.util.List.of("*"));
            corsConfiguration.setAllowCredentials(true);
            corsConfiguration.setMaxAge(3600L);
            return corsConfiguration;
        }))
        .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                // 白名单路径无需鉴权
                .requestMatchers("/api/auth/login", "/api/auth/register", "/api/auth/admin/login",
                                 "/api/admin/login", "/api/admin/register").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()

                // === 角色路径权限规则 ===

                // AI配置 —— 仅管理员
                .requestMatchers("/api/ai/configs/**").hasRole("ADMIN")
                // 仪表盘 —— 仅管理员
                .requestMatchers("/api/dashboard/**").hasRole("ADMIN")
                // 管理员管理接口 —— 仅管理员
                .requestMatchers("/api/admin/info").hasRole("ADMIN")

                // 技能写入操作 —— 教师或管理员
                .requestMatchers(HttpMethod.POST, "/api/skills/**").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/skills/**").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/skills/**").hasAnyRole("TEACHER", "ADMIN")

                // 课程/章节/题目写入操作 —— 教师或管理员（排除 students 的提交答案）
                .requestMatchers(HttpMethod.POST, "/api/courses").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/courses/*/sections").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/courses/*/sections/*/questions").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/courses/sections/*/questions").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/courses/**").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/courses/**").hasAnyRole("TEACHER", "ADMIN")

                // 订单写入操作 —— 教师或管理员
                .requestMatchers(HttpMethod.PUT, "/api/orders/**").hasAnyRole("TEACHER", "ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/orders/**").hasAnyRole("TEACHER", "ADMIN")

                // 其他所有 /api/** 请求至少需要认证
                .requestMatchers("/api/**").authenticated()
                .anyRequest().authenticated()
        )
        // 添加 JWT 过滤器（在 UsernamePasswordAuthenticationFilter 之前执行）
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        // 统一异常处理：所有 401/403 返回 JSON，而非 HTML
        .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType("application/json;charset=utf-8");
                    response.getWriter().write("{\"code\":401,\"message\":\"未登录或Token已过期\",\"data\":null}");
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json;charset=utf-8");
                    response.getWriter().write("{\"code\":403,\"message\":\"权限不足，无法访问该资源\",\"data\":null}");
                })
        );

        return http.build();
    }
}
