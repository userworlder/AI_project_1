package com.aicompanion.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderDTO {

    @NotBlank(message = "订单号不能为空")
    private String orderNo;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    private String userNickname;

    @NotNull(message = "金额不能为空")
    private BigDecimal amount;

    @NotBlank(message = "状态不能为空")
    private String status;

    private String description;
}
