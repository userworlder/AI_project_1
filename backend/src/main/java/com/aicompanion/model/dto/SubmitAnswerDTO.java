package com.aicompanion.model.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class SubmitAnswerDTO {

    @NotNull(message = "章节ID不能为空")
    private Long sectionId;

    @NotNull(message = "答案列表不能为空")
    @Valid
    private List<AnswerItem> answers;

    @Data
    public static class AnswerItem {

        private Integer questionId;

        private String answer;
    }
}
