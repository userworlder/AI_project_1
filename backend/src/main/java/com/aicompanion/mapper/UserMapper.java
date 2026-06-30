package com.aicompanion.mapper;

import com.aicompanion.model.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 动态搜索用户
     *
     * @param role    角色筛选（可选）
     * @param keyword 关键词，模糊匹配用户名或昵称（可选）
     * @return 符合条件的用户列表
     */
    List<User> searchUsers(@Param("role") String role,
                           @Param("keyword") String keyword);
}
