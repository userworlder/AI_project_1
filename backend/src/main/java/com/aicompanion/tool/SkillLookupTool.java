package com.aicompanion.tool;

import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.mapper.UserSkillMapper;
import com.aicompanion.model.entity.Skill;
import com.aicompanion.model.entity.UserSkill;
import com.aicompanion.model.vo.SkillInfo;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

/**
 * 技能查询工具
 * <p>
 * AI 通过此工具查询用户对指定技能的掌握情况。
 * 使用 SkillMapper + UserSkillMapper 查询数据库中的技能定义和用户技能记录。
 * </p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SkillLookupTool {

    private final SkillMapper skillMapper;
    private final UserSkillMapper userSkillMapper;

    /**
     * 查询用户对指定技能的掌握情况
     *
     * @param userId    用户ID
     * @param skillName 技能名称，如 "Java"、"MySQL"、"Vue3" 等，支持模糊匹配
     * @return 技能信息（名称、分类、评分、熟练度、描述、难度等级）
     */
    @Tool(description = "查询用户对指定技能的掌握情况。返回技能名称、分类、评分(0-100)、熟练度、描述和难度等级。如果用户没有该技能记录，评分返回0，熟练度返回not_started。")
    public SkillInfo lookupSkill(
            @ToolParam(description = "用户ID") Long userId,
            @ToolParam(description = "技能名称，如'Java'、'MySQL'、'Vue3'、'Spring Boot'等。支持模糊匹配。") String skillName) {

        log.info("SkillLookupTool 被调用: userId={}, skillName={}", userId, skillName);

        // 1. 按技能名称模糊匹配
        LambdaQueryWrapper<Skill> skillWrapper = Wrappers.lambdaQuery(Skill.class)
                .like(Skill::getName, skillName)
                .last("LIMIT 1");
        Skill skill = skillMapper.selectOne(skillWrapper);

        if (skill == null) {
            log.warn("未找到技能: {}", skillName);
            SkillInfo empty = new SkillInfo();
            empty.setSkillName(skillName);
            empty.setScore(0);
            empty.setProficiency("not_started");
            empty.setSkillLevel(0);
            return empty;
        }

        // 2. 查用户对该技能的掌握记录
        LambdaQueryWrapper<UserSkill> usWrapper = Wrappers.lambdaQuery(UserSkill.class)
                .eq(UserSkill::getUserId, userId)
                .eq(UserSkill::getSkillId, skill.getId());
        UserSkill userSkill = userSkillMapper.selectOne(usWrapper);

        // 3. 组装结果
        SkillInfo info = new SkillInfo();
        info.setSkillName(skill.getName());
        info.setCategory(skill.getCategory());
        info.setSkillLevel(skill.getLevel());
        info.setDescription(skill.getDescription());

        if (userSkill != null) {
            info.setScore(userSkill.getScore());
            info.setProficiency(userSkill.getProficiency());
        } else {
            info.setScore(0);
            info.setProficiency("not_started");
        }

        log.info("SkillLookupTool 返回: skillName={}, score={}, proficiency={}",
                info.getSkillName(), info.getScore(), info.getProficiency());

        return info;
    }
}
