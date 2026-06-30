package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.SkillTreeDTO;
import com.aicompanion.model.vo.SkillTreeVO;

import java.util.List;

/**
 * 技能树服务接口
 */
public interface SkillTreeService {

    /**
     * 新增技能
     */
    SkillTreeVO createSkill(SkillTreeDTO skillTreeDTO);

    /**
     * 根据 ID 逻辑删除技能
     */
    void deleteById(Long id);

    /**
     * 根据 ID 查询技能
     */
    SkillTreeVO getById(Long id);

    /**
     * 分页查询技能列表（支持按分类筛选）
     *
     * @param current  当前页码（默认 1）
     * @param size     每页条数（默认 10）
     * @param category 技能分类（可选，为空时查询全部）
     * @return 分页结果
     */
    PageResult<SkillTreeVO> page(Integer current, Integer size, String category);

    /**
     * 根据父 ID 查询子技能列表
     *
     * @param parentId 父节点 ID
     * @return 子技能列表
     */
    List<SkillTreeVO> getByParentId(Long parentId);
}
