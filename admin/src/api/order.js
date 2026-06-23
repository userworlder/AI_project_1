import request from '@/utils/request'

export const getOrderList = (params) => {
  return request({
    url: '/orders',
    method: 'get',
    params
  })
}

export const deleteOrder = (id) => {
  return request({
    url: `/orders/${id}`,
    method: 'delete'
  })
}

export const getOrderById = (id) => {
  return request({
    url: `/orders/${id}`,
    method: 'get'
  })
}
