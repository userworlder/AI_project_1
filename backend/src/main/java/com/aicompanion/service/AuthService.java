package com.aicompanion.service;

import com.aicompanion.model.dto.LoginDTO;
import com.aicompanion.model.vo.LoginVO;

public interface AuthService {

    LoginVO login(LoginDTO loginDTO);

    /** 管理员登录——需校验角色为 admin */
    LoginVO adminLogin(LoginDTO loginDTO);
}
