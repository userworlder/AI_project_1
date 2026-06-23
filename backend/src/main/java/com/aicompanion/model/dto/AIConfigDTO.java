package com.aicompanion.model.dto;

import lombok.Data;

@Data
public class AIConfigDTO {

    private String name;

    private String model;

    private String apiKey;

    private Boolean enabled;

    private String params;
}
