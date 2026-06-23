import request from '@/utils/request'

export const getDashboardStats = () => {
  return request({
    url: '/dashboard/stats',
    method: 'get'
  })
}

export const getUserGrowth = (params) => {
  return request({
    url: '/dashboard/user-growth',
    method: 'get',
    params
  })
}

export const getLearningStats = (params) => {
  return request({
    url: '/dashboard/learning-stats',
    method: 'get',
    params
  })
}
