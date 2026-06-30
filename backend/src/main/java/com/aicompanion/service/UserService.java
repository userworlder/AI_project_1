package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.ChangePasswordDTO;
import com.aicompanion.model.dto.RegisterDTO;
import com.aicompanion.model.dto.UpdateUserDTO;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.UserVO;

import java.util.List;

public interface UserService {

    UserVO register(RegisterDTO registerDTO);

    UserVO getUserById(Long id);

    UserVO updateUser(Long id, UpdateUserDTO updateDTO);

    UserVO getUserVOByUsername(String username);

    void changePassword(String username, ChangePasswordDTO dto);

    PageResult<UserVO> getUsers(Integer current, Integer size, String keyword);

    void deleteUser(Long id);

    User getUserByUsername(String username);

    /**
     * 动态搜索用户（基于 XML Mapper 实现）
     *
     * @param role    角色筛选（可选）
     * @param keyword 关键词，模糊匹配用户名或昵称（可选）
     * @return 用户实体列表
     */
    List<User> searchUsers(String role, String keyword);
}
