package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.model.dto.SkillDTO;
import com.aicompanion.model.entity.Skill;
import com.aicompanion.model.vo.SkillVO;
import com.aicompanion.service.SkillService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SkillServiceImpl implements SkillService {

    private final SkillMapper skillMapper;

    @Override
    public SkillVO createSkill(SkillDTO skillDTO) {
        Skill skill = new Skill();
        BeanUtils.copyProperties(skillDTO, skill);
        skillMapper.insert(skill);
        return convertToVO(skill);
    }

    @Override
    public SkillVO updateSkill(Long id, SkillDTO skillDTO) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        BeanUtils.copyProperties(skillDTO, skill);
        skillMapper.updateById(skill);
        return convertToVO(skill);
    }

    @Override
    public void deleteSkill(Long id) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        skillMapper.deleteById(id);
    }

    @Override
    public SkillVO getSkillById(Long id) {
        Skill skill = skillMapper.selectById(id);
        if (skill == null) {
            throw new BusinessException("技能不存在");
        }
        return convertToVO(skill);
    }

    @Override
    public PageResult<SkillVO> getSkills(Integer current, Integer size, String keyword) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<Skill> page = new Page<>(current, size);
        LambdaQueryWrapper<Skill> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(Skill::getName, keyword)
                   .or().like(Skill::getCategory, keyword);
        }

        wrapper.orderByDesc(Skill::getCreateTime);
        Page<Skill> skillPage = skillMapper.selectPage(page, wrapper);

        List<SkillVO> voList = skillPage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                skillPage.getTotal(),
                skillPage.getCurrent(),
                skillPage.getSize(),
                voList
        );
    }

    @Override
    public List<SkillVO> getSkillsByCategory(String category) {
        LambdaQueryWrapper<Skill> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Skill::getCategory, category);
        wrapper.orderByAsc(Skill::getLevel);
        return skillMapper.selectList(wrapper).stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
    }

    @Override
    public List<SkillVO> getAllSkills() {
        LambdaQueryWrapper<Skill> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Skill::getCategory).orderByAsc(Skill::getLevel);
        return skillMapper.selectList(wrapper).stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
    }

    private SkillVO convertToVO(Skill skill) {
        SkillVO vo = new SkillVO();
        BeanUtils.copyProperties(skill, vo);
        return vo;
    }
}
