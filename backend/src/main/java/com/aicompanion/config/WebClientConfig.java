package com.aicompanion.config;

import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;
import reactor.netty.resources.ConnectionProvider;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

/**
 * WebClient 配置类
 * 优化 DNS 解析、连接池和超时设置，解决 DeepSeek API 访问问题
 */
@Slf4j
@Configuration
public class WebClientConfig {

    /**
     * 配置优化的 WebClient.Builder
     * - 增加连接超时时间到 30 秒
     * - 增加响应超时时间到 60 秒
     * - 配置连接池
     * - 添加读写超时处理器
     */
    @Bean
    public WebClient.Builder webClientBuilder() {
        log.info("初始化优化的 WebClient 配置");

        // 配置连接池
        ConnectionProvider connectionProvider = ConnectionProvider.builder("ai-companion-pool")
                .maxConnections(50)
                .pendingAcquireTimeout(Duration.ofSeconds(30))
                .maxIdleTime(Duration.ofSeconds(60))
                .build();

        // 配置 HttpClient
        HttpClient httpClient = HttpClient.create(connectionProvider)
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 30000)
                .responseTimeout(Duration.ofSeconds(60))
                .doOnConnected(conn -> conn
                        .addHandlerLast(new ReadTimeoutHandler(60, TimeUnit.SECONDS))
                        .addHandlerLast(new WriteTimeoutHandler(60, TimeUnit.SECONDS)));

        return WebClient.builder()
                .clientConnector(new ReactorClientHttpConnector(httpClient));
    }
}
