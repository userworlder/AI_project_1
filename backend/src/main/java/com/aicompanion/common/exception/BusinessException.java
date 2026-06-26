package com.aicompanion.common.exception;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class BusinessException extends RuntimeException {
    private Integer code;

    public BusinessException(String message) {
        super(message);
        this.code = 500;
    }

    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    /** 参数错误（400） */
    public static BusinessException badRequest(String message) {
        return new BusinessException(400, message);
    }

    /** 认证失败（401） */
    public static BusinessException unauthorized(String message) {
        return new BusinessException(401, message);
    }

    /** 权限不足（403） */
    public static BusinessException forbidden(String message) {
        return new BusinessException(403, message);
    }

    /** 资源不存在（404） */
    public static BusinessException notFound(String message) {
        return new BusinessException(404, message);
    }

    /** 冲突（409），如重复注册 */
    public static BusinessException conflict(String message) {
        return new BusinessException(409, message);
    }
}
