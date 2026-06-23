package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.SkillDTO;
import com.aicompanion.model.vo.SkillVO;

import java.util.List;

public interface SkillService {

    SkillVO createSkill(SkillDTO skillDTO);

    SkillVO updateSkill(Long id, SkillDTO skillDTO);

    void deleteSkill(Long id);

    SkillVO getSkillById(Long id);

    PageResult<SkillVO> getSkills(Integer current, Integer size, String keyword);

    List<SkillVO> getSkillsByCategory(String category);

    List<SkillVO> getAllSkills();
}
