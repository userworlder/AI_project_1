package com.aicompanion.controller;

import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.LoginDTO;
import com.aicompanion.model.vo.LoginVO;
import com.aicompanion.model.vo.UserVO;
import com.aicompanion.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理员认证", description = "管理员登录和信息查询接口")
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AuthService authService;

    @Operation(summary = "管理员登录")
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO loginDTO) {
        LoginVO loginVO = authService.login(loginDTO);
        return Result.success("登录成功", loginVO);
    }

    @Operation(summary = "获取管理员信息")
    @GetMapping("/info")
    public Result<UserVO> getInfo() {
        // TODO: 从 SecurityContext 中获取当前用户信息
        // 这里暂时返回 null，需要根据实际的 JWT 解析实现
        return Result.success(null);
    }
}
