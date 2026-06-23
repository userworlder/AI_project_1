package com.aicompanion.controller;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.response.Result;
import com.aicompanion.model.dto.OrderDTO;
import com.aicompanion.model.vo.OrderVO;
import com.aicompanion.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "订单管理", description = "订单相关接口")
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @Operation(summary = "新增订单")
    @PostMapping
    public Result<OrderVO> createOrder(@Valid @RequestBody OrderDTO orderDTO) {
        OrderVO orderVO = orderService.createOrder(orderDTO);
        return Result.success("新增成功", orderVO);
    }

    @Operation(summary = "更新订单")
    @PutMapping("/{id}")
    public Result<OrderVO> updateOrder(@PathVariable Long id, @Valid @RequestBody OrderDTO orderDTO) {
        OrderVO orderVO = orderService.updateOrder(id, orderDTO);
        return Result.success("更新成功", orderVO);
    }

    @Operation(summary = "删除订单")
    @DeleteMapping("/{id}")
    public Result<Void> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return Result.success("删除成功", null);
    }

    @Operation(summary = "获取订单详情")
    @GetMapping("/{id}")
    public Result<OrderVO> getOrderById(@PathVariable Long id) {
        OrderVO orderVO = orderService.getOrderById(id);
        return Result.success(orderVO);
    }

    @Operation(summary = "分页查询订单列表")
    @GetMapping
    public Result<PageResult<OrderVO>> getOrders(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status) {
        PageResult<OrderVO> pageResult = orderService.getOrders(current, size, keyword, status);
        return Result.success(pageResult);
    }
}
