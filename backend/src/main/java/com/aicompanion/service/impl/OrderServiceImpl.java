package com.aicompanion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.aicompanion.common.exception.BusinessException;
import com.aicompanion.common.response.PageResult;
import com.aicompanion.common.util.SecurityUtils;
import com.aicompanion.mapper.OrderMapper;
import com.aicompanion.model.dto.OrderDTO;
import com.aicompanion.model.entity.Order;
import com.aicompanion.model.vo.OrderVO;
import com.aicompanion.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;

    @Override
    public OrderVO createOrder(OrderDTO orderDTO) {
        // 学生只能为自己创建订单
        if (!SecurityUtils.isAdminOrTeacher()) {
            orderDTO.setUserId(SecurityUtils.getCurrentUserId());
        }

        Order order = new Order();
        BeanUtils.copyProperties(orderDTO, order);
        orderMapper.insert(order);
        return convertToVO(order);
    }

    @Override
    public OrderVO updateOrder(Long id, OrderDTO orderDTO) {
        // 此接口已在 SecurityConfig 中限制为教师/管理员可调用
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        BeanUtils.copyProperties(orderDTO, order);
        orderMapper.updateById(order);
        return convertToVO(order);
    }

    @Override
    public void deleteOrder(Long id) {
        // 此接口已在 SecurityConfig 中限制为教师/管理员可调用
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        orderMapper.deleteById(id);
    }

    @Override
    public OrderVO getOrderById(Long id) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        // 校验数据归属：学生只能查看自己的订单
        SecurityUtils.checkAccess(order.getUserId());
        return convertToVO(order);
    }

    @Override
    public PageResult<OrderVO> getOrders(Integer current, Integer size, String keyword, String status) {
        if (current == null || current < 1) current = 1;
        if (size == null || size < 1) size = 10;

        Page<Order> page = new Page<>(current, size);
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();

        // 学生只能查看自己的订单
        if (SecurityUtils.isStudent()) {
            wrapper.eq(Order::getUserId, SecurityUtils.getCurrentUserId());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(Order::getOrderNo, keyword)
                   .or().like(Order::getUserNickname, keyword);
        }
        if (status != null && !status.trim().isEmpty()) {
            wrapper.eq(Order::getStatus, status);
        }

        wrapper.orderByDesc(Order::getCreateTime);
        Page<Order> orderPage = orderMapper.selectPage(page, wrapper);

        List<OrderVO> voList = orderPage.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        return new PageResult<>(
                orderPage.getTotal(),
                orderPage.getCurrent(),
                orderPage.getSize(),
                voList
        );
    }

    private OrderVO convertToVO(Order order) {
        OrderVO vo = new OrderVO();
        BeanUtils.copyProperties(order, vo);
        return vo;
    }
}
