package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.ResumeMapper;
import com.aicompanion.model.dto.ResumeDTO;
import com.aicompanion.model.entity.Resume;
import com.aicompanion.model.vo.ResumeVO;
import com.aicompanion.service.ResumeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ResumeServiceImpl implements ResumeService {

    private final ResumeMapper resumeMapper;
    private final ChatClient.Builder chatClientBuilder;

    @Override
    public ResumeVO evaluateResume(ResumeDTO resumeDTO) {
        // 校验数据归属
        if (!SecurityUtils.isAdminOrTeacher()) {
            resumeDTO.setUserId(SecurityUtils.getCurrentUserId());
        }
        if (resumeDTO.getUserId() == null) {
            throw BusinessException.badRequest("无法识别用户身份");
        }

        // 1. 调用 AI 评估简历
        String prompt = """
            你是一位资深的简历评估专家。请分析以下简历内容，并严格按照JSON格式返回评估结果。
            要求：
            - score: 0-100的整数分数
            - summary: 一段简短的总体评价（不超过200字）
            - strengths: 优势列表（数组，每项不超过100字，3-5项）
            - suggestions: 改进建议列表（数组，每项不超过100字，3-5项）

            简历内容：
            """ + resumeDTO.getContent();

        String aiResponse;
        try {
            ChatClient chatClient = chatClientBuilder.build();
            aiResponse = chatClient.prompt()
                    .system("你是一位资深的简历评估专家。请分析简历并返回严格的JSON格式。只返回JSON，不要包含```markdown代码块标记。")
                    .user(prompt)
                    .call()
                    .content();
        } catch (Exception e) {
            log.error("AI评估简历失败: ", e);
            throw BusinessException.badRequest("AI评估服务暂不可用，请稍后重试");
        }

        // 清理 AI 响应（移除可能的 markdown 代码块标记）
        String cleanedResponse = aiResponse
                .replaceAll("```json\\s*", "")
                .replaceAll("```\\s*", "")
                .trim();

        // 2. 解析 AI 返回的 JSON
        int score = 0;
        String strengths = "";
        String suggestions = "";
        String summary = "";

        try {
            com.fasterxml.jackson.databind.JsonNode root = new com.fasterxml.jackson.databind.ObjectMapper().readTree(cleanedResponse);
            if (root.has("score")) score = root.get("score").asInt();
            if (root.has("summary")) summary = root.get("summary").asText();
            if (root.has("strengths")) {
                var arr = root.get("strengths");
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < arr.size(); i++) {
                    sb.append(i + 1).append(". ").append(arr.get(i).asText()).append("\n");
                }
                strengths = sb.toString().trim();
            }
            if (root.has("suggestions")) {
                var arr = root.get("suggestions");
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < arr.size(); i++) {
                    sb.append(i + 1).append(". ").append(arr.get(i).asText()).append("\n");
                }
                suggestions = sb.toString().trim();
            }
        } catch (Exception e) {
            log.warn("AI响应JSON解析失败，评估结果降级: {}", e.getMessage());
            summary = "AI评估已完成，详情请查看优势和优化建议。";
        }

        // 如果 summary 为空，尝试使用原始响应的前200字符作为摘要
        if (summary.isEmpty() && cleanedResponse != null && !cleanedResponse.isEmpty()) {
            summary = cleanedResponse.length() > 200
                    ? cleanedResponse.substring(0, 200) + "..."
                    : cleanedResponse;
        }

        // 3. 保存评估记录
        Resume resume = new Resume();
        BeanUtils.copyProperties(resumeDTO, resume);
        resume.setScore(score);
        // 只存储格式化后的总体评价（不含AI原始回复）
        resume.setEvaluation(summary);
        resume.setStrengths(strengths);
        resume.setSuggestions(suggestions);
        if (resume.getStatus() == null) {
            resume.setStatus("completed");
        }
        if (resume.getTitle() == null || resume.getTitle().trim().isEmpty()) {
            resume.setTitle("未命名简历");
        }
        resumeMapper.insert(resume);
        log.info("AI简历评估完成: userId={}, title={}, score={}", resume.getUserId(), resume.getTitle(), score);

        return convertToVO(resume);
    }

    @Override
    public ResumeVO createResume(ResumeDTO resumeDTO) {
        // 学生只能为自己创建简历评估
        if (!SecurityUtils.isAdminOrTeacher()) {
            resumeDTO.setUserId(SecurityUtils.getCurrentUserId());
        }

        Resume resume = new Resume();
        BeanUtils.copyProperties(resumeDTO, resume);
        if (resume.getStatus() == null) {
            resume.setStatus("completed");
        }
        if (resume.getTitle() == null || resume.getTitle().trim().isEmpty()) {
            resume.setTitle("未命名简历");
        }
        resumeMapper.insert(resume);
        log.info("创建简历评估记录: userId={}, title={}", resume.getUserId(), resume.getTitle());
        return convertToVO(resume);
    }

    @Override
    public ResumeVO updateResume(Long id, ResumeDTO resumeDTO) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属
        SecurityUtils.checkAccess(resume.getUserId());
        // 学生修改时不能篡改 userId
        if (SecurityUtils.isStudent()) {
            resumeDTO.setUserId(resume.getUserId());
        }

        BeanUtils.copyProperties(resumeDTO, resume);
        resumeMapper.updateById(resume);
        return convertToVO(resume);
    }

    @Override
    public void deleteResume(Long id) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属
        SecurityUtils.checkAccess(resume.getUserId());
        resumeMapper.deleteById(id);
    }

    @Override
    public ResumeVO getResumeById(Long id) {
        Resume resume = resumeMapper.selectById(id);
        if (resume == null) {
            throw new BusinessException("简历记录不存在");
        }
        // 校验数据归属：学生只能查看自己的简历
        SecurityUtils.checkAccess(resume.getUserId());
        return convertToVO(resume);
    }

    @Override
    public List<ResumeVO> getResumesByUserId(Long userId) {
        // 学生只能查看自己的简历列表
        if (SecurityUtils.isStudent()) {
            userId = SecurityUtils.getCurrentUserId();
        }

        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Resume::getUserId, userId);
        wrapper.orderByDesc(Resume::getCreateTime);
        return resumeMapper.selectList(wrapper).stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
    }

    @Override
    public PageResult<ResumeVO> getResumes(Integer current, Integer size, Long userId) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<Resume> page = new Page<>(current, size);
        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<>();

        // 学生只能查询自己的简历评估
        if (SecurityUtils.isStudent()) {
            userId = SecurityUtils.getCurrentUserId();
        }

        if (userId != null) {
            wrapper.eq(Resume::getUserId, userId);
        }

        wrapper.orderByDesc(Resume::getCreateTime);
        Page<Resume> resumePage = resumeMapper.selectPage(page, wrapper);

        List<ResumeVO> voList = resumePage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                resumePage.getTotal(),
                resumePage.getCurrent(),
                resumePage.getSize(),
                voList
        );
    }

    private ResumeVO convertToVO(Resume resume) {
        ResumeVO vo = new ResumeVO();
        BeanUtils.copyProperties(resume, vo);
        // 清理旧数据：如果 evaluation 包含 "---" 分隔符，只保留前面的部分
        if (vo.getEvaluation() != null && vo.getEvaluation().contains("\n\n---\n")) {
            vo.setEvaluation(vo.getEvaluation().substring(0, vo.getEvaluation().indexOf("\n\n---\n")));
        }
        return vo;
    }
}
