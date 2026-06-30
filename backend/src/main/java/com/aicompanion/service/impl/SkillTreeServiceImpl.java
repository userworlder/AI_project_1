package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.mapper.SkillTreeMapper;
import com.aicompanion.model.dto.SkillTreeDTO;
import com.aicompanion.model.entity.SkillTree;
import com.aicompanion.model.vo.SkillTreeVO;
import com.aicompanion.service.SkillTreeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 技能树服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SkillTreeServiceImpl implements SkillTreeService {

    private final SkillTreeMapper skillTreeMapper;

    @Override
    public SkillTreeVO createSkill(SkillTreeDTO skillTreeDTO) {
        SkillTree skillTree = new SkillTree();
        BeanUtils.copyProperties(skillTreeDTO, skillTree);
        skillTreeMapper.insert(skillTree);
        log.info("新增技能树节点成功，id={}", skillTree.getId());
        return convertToVO(skillTree);
    }

    @Override
    public void deleteById(Long id) {
        SkillTree skillTree = skillTreeMapper.selectById(id);
        if (skillTree == null) {
            throw BusinessException.notFound("技能节点不存在");
        }
        // 逻辑删除（由 MyBatis-Plus 全局配置自动填充 deleted=1）
        skillTreeMapper.deleteById(id);
        log.info("逻辑删除技能树节点成功，id={}", id);
    }

    @Override
    public SkillTreeVO getById(Long id) {
        SkillTree skillTree = skillTreeMapper.selectById(id);
        if (skillTree == null) {
            throw BusinessException.notFound("技能节点不存在");
        }
        return convertToVO(skillTree);
    }

    @Override
    public PageResult<SkillTreeVO> page(Integer current, Integer size, String category) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<SkillTree> page = new Page<>(current, size);
        LambdaQueryWrapper<SkillTree> wrapper = new LambdaQueryWrapper<>();

        // 按分类筛选（非空时）
        if (category != null && !category.trim().isEmpty()) {
            wrapper.eq(SkillTree::getCategory, category.trim());
        }

        // 按创建时间降序排列
        wrapper.orderByDesc(SkillTree::getCreateTime);

        Page<SkillTree> skillTreePage = skillTreeMapper.selectPage(page, wrapper);

        List<SkillTreeVO> voList = skillTreePage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                skillTreePage.getTotal(),
                skillTreePage.getCurrent(),
                skillTreePage.getSize(),
                voList
        );
    }

    @Override
    public List<SkillTreeVO> getByParentId(Long parentId) {
        LambdaQueryWrapper<SkillTree> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SkillTree::getParentId, parentId);
        wrapper.orderByAsc(SkillTree::getLevel).orderByAsc(SkillTree::getCreateTime);
        return skillTreeMapper.selectList(wrapper).stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
    }

    /**
     * 将实体转换为 VO
     */
    private SkillTreeVO convertToVO(SkillTree skillTree) {
        SkillTreeVO vo = new SkillTreeVO();
        BeanUtils.copyProperties(skillTree, vo);
        return vo;
    }
}
