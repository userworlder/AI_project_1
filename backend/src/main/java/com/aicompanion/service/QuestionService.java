package com.aicompanion.service;

import com.aicompanion.model.dto.QuestionDTO;
import com.aicompanion.model.dto.SubmitAnswerDTO;
import com.aicompanion.model.vo.QuestionVO;
import com.aicompanion.model.vo.SubmitResultVO;

import java.util.List;

public interface QuestionService {

    QuestionVO createQuestion(QuestionDTO questionDTO);

    QuestionVO updateQuestion(Long id, QuestionDTO questionDTO);

    void deleteQuestion(Long id);

    List<QuestionVO> getQuestionsBySectionId(Long sectionId, boolean includeAnswer);

    SubmitResultVO submitAnswers(Long userId, SubmitAnswerDTO submitAnswerDTO);
}
