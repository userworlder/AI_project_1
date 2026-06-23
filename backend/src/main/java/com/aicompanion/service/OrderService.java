package com.aicompanion.service;

import com.aicompanion.common.response.PageResult;
import com.aicompanion.model.dto.OrderDTO;
import com.aicompanion.model.vo.OrderVO;

public interface OrderService {

    OrderVO createOrder(OrderDTO orderDTO);

    OrderVO updateOrder(Long id, OrderDTO orderDTO);

    void deleteOrder(Long id);

    OrderVO getOrderById(Long id);

    PageResult<OrderVO> getOrders(Integer current, Integer size, String keyword, String status);
}
