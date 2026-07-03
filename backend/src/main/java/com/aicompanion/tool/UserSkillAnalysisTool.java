package com.aicompanion.tool;

import com.aicompanion.mapper.SkillMapper;
import com.aicompanion.mapper.UserSkillMapper;
import com.aicompanion.model.entity.Skill;
import com.aicompanion.model.entity.UserSkill;
import com.aicompanion.model.vo.SkillAnalysis;
import com.aicompanion.model.vo.SkillInfo;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 用户技能分析工具
 * <p>
 * AI 通过此工具分析用户的完整技能画像，包括所有技能的评分、最强/最弱分类和综合评估。
 * 用于 AI 在学习评估、面试准备等场景中了解用户的整体技能水平。
 * </p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class UserSkillAnalysisTool {

    private final SkillMapper skillMapper;
    private final UserSkillMapper userSkillMapper;

    /**
     * 分析用户的完整技能画像
     *
     * @param userId 用户ID
     * @return 技能分析结果（技能列表、平均分、最强/最弱分类、综合评估）
     */
    @Tool(description = "分析用户的完整技能画像。返回用户所有技能的详细列表、总技能数、平均分、最强分类、最弱分类，以及综合评估文字。")
    public SkillAnalysis analyzeUserSkills(
            @ToolParam(description = "用户ID") Long userId) {

        log.info("UserSkillAnalysisTool 被调用: userId={}", userId);

        // 1. 查询该用户的所有技能记录
        LambdaQueryWrapper<UserSkill> usWrapper = Wrappers.lambdaQuery(UserSkill.class)
                .eq(UserSkill::getUserId, userId);
        List<UserSkill> userSkills = userSkillMapper.selectList(usWrapper);

        // 2. 查询所有技能定义（用于映射名称）
        List<Skill> allSkills = skillMapper.selectList(Wrappers.lambdaQuery(Skill.class));
        Map<Long, Skill> skillMap = allSkills.stream()
                .collect(Collectors.toMap(Skill::getId, s -> s));

        // 3. 构建 SkillInfo 列表
        List<SkillInfo> skillInfos = new ArrayList<>();
        for (UserSkill us : userSkills) {
            Skill skill = skillMap.get(us.getSkillId());
            if (skill == null) {
                continue;
            }

            SkillInfo info = new SkillInfo();
            info.setSkillName(skill.getName());
            info.setCategory(skill.getCategory());
            info.setScore(us.getScore());
            info.setProficiency(us.getProficiency());
            info.setDescription(skill.getDescription());
            info.setSkillLevel(skill.getLevel());
            skillInfos.add(info);
        }

        // 4. 计算分析指标
        SkillAnalysis analysis = new SkillAnalysis();
        analysis.setSkills(skillInfos);
        analysis.setTotalSkills(skillInfos.size());

        if (skillInfos.isEmpty()) {
            analysis.setAverageScore(0.0);
            analysis.setStrongestCategory("无");
            analysis.setWeakestCategory("无");
            analysis.setOverallAssessment("该用户尚未学习任何技能，建议从基础课程开始。");
            log.info("UserSkillAnalysisTool 返回: 无技能记录");
            return analysis;
        }

        // 平均分
        double avgScore = skillInfos.stream()
                .mapToInt(SkillInfo::getScore)
                .average()
                .orElse(0.0);
        analysis.setAverageScore(Math.round(avgScore * 10.0) / 10.0);

        // 按分类计算平均分，找出最强/最弱分类
        Map<String, Double> categoryAvg = skillInfos.stream()
                .collect(Collectors.groupingBy(
                        SkillInfo::getCategory,
                        Collectors.averagingInt(SkillInfo::getScore)
                ));

        String strongest = categoryAvg.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("无");

        String weakest = categoryAvg.entrySet().stream()
                .min(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("无");

        analysis.setStrongestCategory(strongest);
        analysis.setWeakestCategory(weakest);

        // 综合评估
        String assessment;
        if (avgScore >= 80) {
            assessment = "整体技能水平优秀，建议继续保持并挑战更高难度内容。";
        } else if (avgScore >= 60) {
            assessment = "整体技能水平良好，有较好的基础，建议在「" + weakest + "」方向加强练习，进一步提升综合能力。";
        } else if (avgScore >= 40) {
            assessment = "整体技能水平一般，需要加强基础训练，特别是「" + weakest + "」方向。建议制定系统学习计划，多动手实践。";
        } else {
            assessment = "技能水平有待提升，建议从基础课程开始系统学习，打好坚实基础。";
        }
        analysis.setOverallAssessment(assessment);

        log.info("UserSkillAnalysisTool 返回: totalSkills={}, avgScore={}, strongest={}, weakest={}",
                analysis.getTotalSkills(), analysis.getAverageScore(), strongest, weakest);

        return analysis;
    }
}
