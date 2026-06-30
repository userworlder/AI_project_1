package com.aicompanion.controller;

import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.model.dto.ChangePasswordDTO;
import com.aicompanion.model.dto.RegisterDTO;
import com.aicompanion.model.dto.UpdateUserDTO;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.UserVO;
import com.aicompanion.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @Operation(summary = "获取当前登录用户信息")
    @GetMapping("/me")
    public Result<UserVO> getCurrentUser(Authentication authentication) {
        String username = authentication.getName();
        UserVO userVO = userService.getUserVOByUsername(username);
        return Result.success(userVO);
    }

    @Operation(summary = "修改当前用户密码")
    @PutMapping("/me/password")
    public Result<Void> changePassword(Authentication authentication,
                                       @Valid @RequestBody ChangePasswordDTO dto) {
        String username = authentication.getName();
        userService.changePassword(username, dto);
        return Result.success("密码修改成功", null);
    }

    @Operation(summary = "获取用户信息（本人或管理员）")
    @GetMapping("/{id}")
    public Result<UserVO> getUserById(@PathVariable Long id) {
        Long currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            throw BusinessException.unauthorized("无法识别用户身份");
        }
        if (!SecurityUtils.isAdminOrTeacher() && !currentUserId.equals(id)) {
            throw BusinessException.forbidden("无权限查看该用户信息");
        }
        UserVO userVO = userService.getUserById(id);
        return Result.success(userVO);
    }

    @Operation(summary = "更新用户信息（管理员）")
    @PutMapping("/{id}")
    public Result<UserVO> updateUser(@PathVariable Long id,
                                     @Valid @RequestBody UpdateUserDTO updateDTO) {
        SecurityUtils.checkAdmin();
        UserVO userVO = userService.updateUser(id, updateDTO);
        return Result.success("更新成功", userVO);
    }

    @Operation(summary = "分页查询用户列表（管理员）")
    @GetMapping
    public Result<PageResult<UserVO>> getUsers(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        SecurityUtils.checkAdmin();
        PageResult<UserVO> pageResult = userService.getUsers(current, size, keyword);
        return Result.success(pageResult);
    }

    @Operation(summary = "分页查询用户列表（兼容旧路径，管理员）")
    @GetMapping("/list")
    public Result<PageResult<UserVO>> getUsersList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        SecurityUtils.checkAdmin();
        PageResult<UserVO> pageResult = userService.getUsers(current, size, keyword);
        return Result.success(pageResult);
    }

    @Operation(summary = "删除用户（管理员）")
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        SecurityUtils.checkAdmin();
        userService.deleteUser(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "动态搜索用户（管理员）", description = "支持按角色筛选、按用户名/昵称模糊搜索")
    @GetMapping("/search")
    public Result<List<User>> searchUsers(
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String keyword) {
        SecurityUtils.checkAdmin();
        List<User> userList = userService.searchUsers(role, keyword);
        return Result.success(userList);
    }
}
