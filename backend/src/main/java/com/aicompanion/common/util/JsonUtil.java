package com.aicompanion.common.util;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * JSON 解析工具类，专门用于从 AI 回复中提取结构化 JSON 数据。
 * <p>
 * AI 有时会在 JSON 前后加废话（如 "好的，这是结果：\n{...}\n希望对你有帮助"），
 * 或者用 ```json ... ``` 代码块包裹，此类能自动处理这些情况。
 */
@Slf4j
public final class JsonUtil {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final Pattern JSON_BLOCK_PATTERN =
            Pattern.compile("```(?:json)?\\s*([\\s\\S]*?)\\s*```", Pattern.MULTILINE);
    private static final Pattern JSON_OBJECT_PATTERN =
            Pattern.compile("\\{.*\\}", Pattern.DOTALL);
    private static final Pattern JSON_ARRAY_PATTERN =
            Pattern.compile("\\[.*\\]", Pattern.DOTALL);

    private JsonUtil() {
        // 工具类禁止实例化
    }

    /**
     * 从 AI 回复文本中提取 JSON 数组并解析为 List&lt;Map&gt;
     *
     * @param text AI 回复文本
     * @return 解析后的 List&lt;Map&lt;String, Object&gt;&gt;
     * @throws RuntimeException 如果无法提取或解析 JSON
     */
    public static List<Map<String, Object>> extractMapList(String text) {
        try {
            String json = extractJson(text, false);
            return OBJECT_MAPPER.readValue(json, new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception e) {
            log.error("从 AI 回复提取 JSON 数组失败: {}", text, e);
            throw new RuntimeException("AI 返回格式异常，无法解析数据列表", e);
        }
    }

    /**
     * 从 AI 回复文本中提取 JSON 对象并解析为 Map
     *
     * @param text AI 回复文本
     * @return 解析后的 Map&lt;String, Object&gt;
     * @throws RuntimeException 如果无法提取或解析 JSON
     */
    public static Map<String, Object> extractMap(String text) {
        try {
            String json = extractJson(text, true);
            return OBJECT_MAPPER.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            log.error("从 AI 回复提取 JSON 对象失败: {}", text, e);
            throw new RuntimeException("AI 返回格式异常，无法解析评估结果", e);
        }
    }

    /**
     * 从文本中提取 JSON 字符串，支持以下格式：
     * 1. 纯 JSON（{...} 或 [...]）
     * 2. Markdown 代码块包裹的 JSON（```json ... ```）
     * 3. 前/后有额外文字描述
     *
     * @param text      AI 回复文本
     * @param isObject  true 表示期望 JSON 对象，false 表示期望 JSON 数组
     * @return 提取的 JSON 字符串
     */
    private static String extractJson(String text, boolean isObject) {
        if (text == null || text.isBlank()) {
            throw new IllegalArgumentException("AI 回复内容为空");
        }

        // 1. 优先尝试提取 Markdown 代码块中的 JSON
        Matcher blockMatcher = JSON_BLOCK_PATTERN.matcher(text);
        if (blockMatcher.find()) {
            String candidate = blockMatcher.group(1).trim();
            if (isValidJson(candidate)) {
                return candidate;
            }
        }

        // 2. 尝试用正则直接匹配最外层的 {} 或 []
        Pattern pattern = isObject ? JSON_OBJECT_PATTERN : JSON_ARRAY_PATTERN;
        Matcher matcher = pattern.matcher(text);

        String longest = null;
        while (matcher.find()) {
            String candidate = matcher.group();
            if (longest == null || candidate.length() > longest.length()) {
                longest = candidate;
            }
        }

        if (longest != null && isValidJson(longest)) {
            return longest;
        }

        // 3. 回退：用 indexOf/lastIndexOf 简单提取
        char startChar = isObject ? '{' : '[';
        char endChar = isObject ? '}' : ']';
        int start = text.indexOf(startChar);
        int end = text.lastIndexOf(endChar);

        if (start >= 0 && end > start) {
            String fallback = text.substring(start, end + 1);
            if (isValidJson(fallback)) {
                return fallback;
            }
        }

        // 4. 最后的尝试：直接解析整个文本
        String trimmed = text.trim();
        if (isValidJson(trimmed)) {
            return trimmed;
        }

        throw new RuntimeException("无法从 AI 回复中提取有效的 JSON");
    }

    /**
     * 快速校验字符串是否为有效的 JSON
     */
    private static boolean isValidJson(String json) {
        try {
            if (json.trim().startsWith("{")) {
                OBJECT_MAPPER.readTree(json);
            } else if (json.trim().startsWith("[")) {
                OBJECT_MAPPER.readTree(json);
            } else {
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
