package com.aicompanion.common.util;

import com.aicompanion.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * 安全工具类 —— 从 SecurityContextHolder 获取当前登录用户信息
 */
@Slf4j
@Component
public class SecurityUtils {

    /**
     * 获取当前登录用户的完整信息
     */
    public static AuthUser getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof AuthUser) {
            return (AuthUser) auth.getDetails();
        }
        return null;
    }

    /**
     * 获取当前登录用户 ID
     */
    public static Long getCurrentUserId() {
        AuthUser user = getCurrentUser();
        return user != null ? user.getUserId() : null;
    }

    /**
     * 获取当前登录用户的角色（小写：student / teacher / admin）
     */
    public static String getCurrentUserRole() {
        AuthUser user = getCurrentUser();
        return user != null ? user.getRole() : null;
    }

    /**
     * 当前用户是否拥有指定角色
     */
    public static boolean hasRole(String role) {
        String currentRole = getCurrentUserRole();
        return currentRole != null && currentRole.equalsIgnoreCase(role);
    }

    /**
     * 当前用户是否为管理员
     */
    public static boolean isAdmin() {
        return hasRole("admin");
    }

    /**
     * 当前用户是否为教师
     */
    public static boolean isTeacher() {
        return hasRole("teacher");
    }

    /**
     * 当前用户是否为学生
     */
    public static boolean isStudent() {
        return hasRole("student");
    }

    /**
     * 当前用户是否为管理员或教师
     */
    public static boolean isAdminOrTeacher() {
        return isAdmin() || isTeacher();
    }

    /**
     * 校验当前用户是否有权操作指定用户ID的数据
     * 学生只能操作自己的数据；教师和管理员可以操作所有数据
     */
    public static boolean canAccessUserData(Long targetUserId) {
        if (isAdminOrTeacher()) {
            return true;
        }
        Long currentUserId = getCurrentUserId();
        return currentUserId != null && currentUserId.equals(targetUserId);
    }

    /**
     * 校验失败时抛出未授权异常
     */
    public static void checkAccess(Long targetUserId) {
        if (!canAccessUserData(targetUserId)) {
            throw BusinessException.forbidden("无权限访问该资源");
        }
    }

    /**
     * 仅管理员可操作
     */
    public static void checkAdmin() {
        if (!isAdmin()) {
            throw BusinessException.forbidden("仅管理员可执行该操作");
        }
    }

    /**
     * 教师或管理员可操作
     */
    public static void checkAdminOrTeacher() {
        if (!isAdminOrTeacher()) {
            throw BusinessException.forbidden("无权限执行该操作");
        }
    }
}
