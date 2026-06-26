package com.aicompanion.common.util;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * 当前登录用户信息，存放于 SecurityContext Authentication 的 details 中
 */
@Data
@AllArgsConstructor
public class AuthUser {
    private Long userId;
    private String role;
    private String username;
}
