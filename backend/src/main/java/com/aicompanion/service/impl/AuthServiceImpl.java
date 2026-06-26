package com.aicompanion.service.impl;

import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.util.JwtUtil;
import com.aicompanion.model.dto.LoginDTO;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.LoginVO;
import com.aicompanion.model.vo.UserVO;
import com.aicompanion.service.AuthService;
import com.aicompanion.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Override
    public LoginVO login(LoginDTO loginDTO) {
        // 查询用户
        User user = userService.getUserByUsername(loginDTO.getUsername());
        if (user == null) {
            throw BusinessException.unauthorized("用户名或密码错误");
        }

        // 验证密码
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPassword())) {
            throw BusinessException.unauthorized("用户名或密码错误");
        }

        // 检查用户状态
        if (user.getStatus() == 0) {
            throw BusinessException.unauthorized("账号已被禁用");
        }

        // 生成 Token（携带角色和用户ID，用于后续权限校验）
        String token = jwtUtil.generateToken(user.getUsername(), user.getRole(), user.getId());

        // 构建返回对象
        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);

        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(user, userVO);
        loginVO.setUser(userVO);

        return loginVO;
    }

    @Override
    public LoginVO adminLogin(LoginDTO loginDTO) {
        LoginVO loginVO = this.login(loginDTO);
        // 校验角色必须为 admin
        if (loginVO.getUser() == null || !"admin".equals(loginVO.getUser().getRole())) {
            throw BusinessException.forbidden("仅管理员可登录管理后台");
        }
        return loginVO;
    }
}
