package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.RegisterDTO;
import com.aicompanion.model.dto.UpdateUserDTO;
import com.aicompanion.model.entity.User;
import com.aicompanion.model.vo.UserVO;

public interface UserService {

    UserVO register(RegisterDTO registerDTO);

    UserVO getUserById(Long id);

    UserVO updateUser(Long id, UpdateUserDTO updateDTO);

    PageResult<UserVO> getUsers(Integer current, Integer size, String keyword);

    void deleteUser(Long id);

    User getUserByUsername(String username);
}
