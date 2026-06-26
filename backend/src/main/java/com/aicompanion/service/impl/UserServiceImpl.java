package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.mapper.UserMapper;
import com.aicompanion.model.dto.ChangePasswordDTO;
import com.aicompanion.model.dto.RegisterDTO;
import com.aicompanion.model.dto.UpdateUserDTO;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.UserVO;
import com.aicompanion.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserVO register(RegisterDTO registerDTO) {
        // 检查用户名是否已存在
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, registerDTO.getUsername());
        User existUser = userMapper.selectOne(wrapper);
        if (existUser != null) {
            throw BusinessException.conflict("用户名已存在");
        }

        // 创建新用户
        User user = new User();
        BeanUtils.copyProperties(registerDTO, user);
        user.setPassword(passwordEncoder.encode(registerDTO.getPassword()));
        // 默认角色为学生
        if (user.getRole() == null) {
            user.setRole("student");
        }
        user.setStatus(1);

        userMapper.insert(user);

        return convertToVO(user);
    }

    @Override
    public UserVO getUserById(Long id) {
        if (id == null || id <= 0) {
            throw BusinessException.badRequest("无效的用户ID");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    public UserVO updateUser(Long id, UpdateUserDTO updateDTO) {
        if (id == null || id <= 0) {
            throw BusinessException.badRequest("无效的用户ID");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }

        BeanUtils.copyProperties(updateDTO, user);
        userMapper.updateById(user);

        return convertToVO(user);
    }

    @Override
    public PageResult<UserVO> getUsers(Integer current, Integer size, String keyword) {
        if (current == null || current < 1) {
            current = 1;
        }
        if (size == null || size < 1) {
            size = 10;
        }

        Page<User> page = new Page<>(current, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索（用户名、昵称、邮箱）
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.and(w -> w.like(User::getUsername, keyword)
                    .or().like(User::getNickname, keyword)
                    .or().like(User::getEmail, keyword));
        }

        wrapper.orderByDesc(User::getCreateTime);
        
        Page<User> userPage = userMapper.selectPage(page, wrapper);
        
        List<UserVO> voList = userPage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                userPage.getTotal(),
                userPage.getCurrent(),
                userPage.getSize(),
                voList
        );
    }

    @Override
    public void deleteUser(Long id) {
        if (id == null || id <= 0) {
            throw BusinessException.badRequest("无效的用户ID");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }
        userMapper.deleteById(id);
    }

    @Override
    public UserVO getUserVOByUsername(String username) {
        User user = this.getUserByUsername(username);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    public void changePassword(String username, ChangePasswordDTO dto) {
        User user = this.getUserByUsername(username);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }
        // 验证原密码
        if (!passwordEncoder.matches(dto.getOldPassword(), user.getPassword())) {
            throw BusinessException.badRequest("原密码错误");
        }
        // 检查新密码与旧密码是否相同
        if (passwordEncoder.matches(dto.getNewPassword(), user.getPassword())) {
            throw BusinessException.badRequest("新密码不能与旧密码相同");
        }
        // 加密并保存新密码
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userMapper.updateById(user);
        log.info("用户 {} 密码修改成功", username);
    }

    @Override
    public User getUserByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return userMapper.selectOne(wrapper);
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        return vo;
    }
}
