package com.aicompanion.service;

import com.aicompanion.model.dto.LoginDTO;
import com.aicompanion.model.vo.LoginVO;

public interface AuthService {

    LoginVO login(LoginDTO loginDTO);
}
