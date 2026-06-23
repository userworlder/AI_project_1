import request from '@/utils/request'

export const getAiList = (params) => {
  return request({
    url: '/ai/configs',
    method: 'get',
    params
  })
}

export const getAiById = (id) => {
  return request({
    url: `/ai/configs/${id}`,
    method: 'get'
  })
}

export const createAi = (data) => {
  return request({
    url: '/ai/configs',
    method: 'post',
    data
  })
}

export const updateAi = (id, data) => {
  return request({
    url: `/ai/configs/${id}`,
    method: 'put',
    data
  })
}

export const deleteAi = (id) => {
  return request({
    url: `/ai/configs/${id}`,
    method: 'delete'
  })
}

export const getAiStats = () => {
  return request({
    url: '/ai/stats',
    method: 'get'
  })
}
