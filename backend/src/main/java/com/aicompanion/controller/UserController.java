package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.RegisterDTO;
import com.aicompanion.model.dto.UpdateUserDTO;
import com.aicompanion.model.vo.UserVO;
import com.aicompanion.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "用户管理", description = "用户相关接口")
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "注册用户")
    @PostMapping("/register")
    public Result<UserVO> register(@Valid @RequestBody RegisterDTO registerDTO) {
        UserVO userVO = userService.register(registerDTO);
        return Result.success("注册成功", userVO);
    }

    @Operation(summary = "获取用户信息")
    @GetMapping("/{id}")
    public Result<UserVO> getUserById(@PathVariable Long id) {
        UserVO userVO = userService.getUserById(id);
        return Result.success(userVO);
    }

    @Operation(summary = "更新用户信息")
    @PutMapping("/{id}")
    public Result<UserVO> updateUser(@PathVariable Long id, 
                                     @Valid @RequestBody UpdateUserDTO updateDTO) {
        UserVO userVO = userService.updateUser(id, updateDTO);
        return Result.success("更新成功", userVO);
    }

    @Operation(summary = "获取用户列表")
    @GetMapping("/list")
    public Result<PageResult<UserVO>> getUsers(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size) {
        PageResult<UserVO> pageResult = userService.getUsers(current, size);
        return Result.success(pageResult);
    }

    @Operation(summary = "删除用户")
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success("删除成功", null);
    }
}
