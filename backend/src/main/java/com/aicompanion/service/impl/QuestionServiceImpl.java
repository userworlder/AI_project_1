package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.mapper.CourseMapper;
import com.aicompanion.mapper.CourseSectionMapper;
import com.aicompanion.mapper.QuestionMapper;
import com.aicompanion.mapper.StudyRecordMapper;
import com.aicompanion.mapper.UserCourseProgressMapper;
import com.aicompanion.model.dto.QuestionDTO;
import com.aicompanion.model.dto.SubmitAnswerDTO;
import com.aicompanion.model.entity.Course;
import com.aicompanion.model.entity.CourseSection;
import com.aicompanion.model.entity.Question;
import com.aicompanion.model.entity.StudyRecord;
import com.aicompanion.model.entity.UserCourseProgress;
import com.aicompanion.model.vo.QuestionVO;
import com.aicompanion.model.vo.SubmitResultVO;
import com.aicompanion.service.QuestionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionServiceImpl implements QuestionService {

    private final QuestionMapper questionMapper;
    private final CourseSectionMapper courseSectionMapper;
    private final CourseMapper courseMapper;
    private final UserCourseProgressMapper userCourseProgressMapper;
    private final StudyRecordMapper studyRecordMapper;

    @Override
    public QuestionVO createQuestion(QuestionDTO questionDTO) {
        Question question = new Question();
        BeanUtils.copyProperties(questionDTO, question);
        questionMapper.insert(question);
        return convertToVO(question);
    }

    @Override
    public QuestionVO updateQuestion(Long id, QuestionDTO questionDTO) {
        Question question = questionMapper.selectById(id);
        if (question == null) {
            throw new BusinessException("题目不存在");
        }
        BeanUtils.copyProperties(questionDTO, question);
        questionMapper.updateById(question);
        return convertToVO(question);
    }

    @Override
    public void deleteQuestion(Long id) {
        Question question = questionMapper.selectById(id);
        if (question == null) {
            throw new BusinessException("题目不存在");
        }
        questionMapper.deleteById(id);
    }

    @Override
    public List<QuestionVO> getQuestionsBySectionId(Long sectionId, boolean includeAnswer) {
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Question::getSectionId, sectionId);
        wrapper.orderByAsc(Question::getOrderIndex);

        return questionMapper.selectList(wrapper).stream()
                .map(question -> {
                    QuestionVO vo = convertToVO(question);
                    if (!includeAnswer) {
                        vo.setCorrectAnswer(null);
                    }
                    return vo;
                })
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SubmitResultVO submitAnswers(Long userId, SubmitAnswerDTO submitAnswerDTO) {
        // Validate section exists
        CourseSection section = courseSectionMapper.selectById(submitAnswerDTO.getSectionId());
        if (section == null) {
            throw new BusinessException("章节不存在");
        }

        // Get course info for StudyRecord content
        Course course = courseMapper.selectById(section.getCourseId());

        // Get all questions for the section
        LambdaQueryWrapper<Question> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Question::getSectionId, submitAnswerDTO.getSectionId());
        List<Question> questions = questionMapper.selectList(wrapper);

        if (questions.isEmpty()) {
            throw new BusinessException("该章节暂无题目");
        }

        // Build answer map: questionId -> answer
        Map<Long, String> answerMap = submitAnswerDTO.getAnswers().stream()
                .collect(Collectors.toMap(
                        item -> item.getQuestionId().longValue(),
                        SubmitAnswerDTO.AnswerItem::getAnswer
                ));

        // Compare answers
        int correctCount = 0;
        int totalQuestions = questions.size();

        for (Question question : questions) {
            String userAnswer = answerMap.get(question.getId());
            if (userAnswer != null && userAnswer.equals(question.getCorrectAnswer())) {
                correctCount++;
            }
        }

        // Calculate score
        int score = totalQuestions > 0 ? (correctCount * 100 / totalQuestions) : 0;

        // Upsert UserCourseProgress
        LambdaQueryWrapper<UserCourseProgress> progressQuery = new LambdaQueryWrapper<>();
        progressQuery.eq(UserCourseProgress::getUserId, userId);
        progressQuery.eq(UserCourseProgress::getSectionId, submitAnswerDTO.getSectionId());
        progressQuery.eq(UserCourseProgress::getCourseId, section.getCourseId());

        UserCourseProgress progress = userCourseProgressMapper.selectOne(progressQuery);
        if (progress == null) {
            progress = new UserCourseProgress();
            progress.setUserId(userId);
            progress.setCourseId(section.getCourseId());
            progress.setSectionId(submitAnswerDTO.getSectionId());
            progress.setScore(score);
            progress.setTotalQuestions(totalQuestions);
            progress.setCorrectCount(correctCount);
            progress.setStatus(2); // completed
            userCourseProgressMapper.insert(progress);
        } else {
            progress.setScore(score);
            progress.setTotalQuestions(totalQuestions);
            progress.setCorrectCount(correctCount);
            progress.setStatus(2);
            userCourseProgressMapper.updateById(progress);
        }

        // Auto-create StudyRecord
        StudyRecord record = new StudyRecord();
        record.setUserId(userId);
        String content = (course != null ? course.getName() : "") + " - " + section.getTitle();
        record.setContent(content);
        record.setDuration(10);
        record.setType("章节答题");
        record.setStatus(2); // completed
        studyRecordMapper.insert(record);

        // Build result
        SubmitResultVO result = new SubmitResultVO();
        result.setScore(score);
        result.setTotalQuestions(totalQuestions);
        result.setCorrectCount(correctCount);
        result.setSectionId(submitAnswerDTO.getSectionId());

        log.info("User {} submitted answers for section {}, score: {}/{}",
                userId, submitAnswerDTO.getSectionId(), correctCount, totalQuestions);

        return result;
    }

    private QuestionVO convertToVO(Question question) {
        QuestionVO vo = new QuestionVO();
        BeanUtils.copyProperties(question, vo);
        return vo;
    }
}
