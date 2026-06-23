import request from '@/utils/request'

export const getRecordList = (params) => {
  return request({
    url: '/records',
    method: 'get',
    params
  })
}

export const getRecordById = (id) => {
  return request({
    url: `/records/${id}`,
    method: 'get'
  })
}

export const createRecord = (data) => {
  return request({
    url: '/records',
    method: 'post',
    data
  })
}

export const updateRecord = (id, data) => {
  return request({
    url: `/records/${id}`,
    method: 'put',
    data
  })
}

export const deleteRecord = (id) => {
  return request({
    url: `/records/${id}`,
    method: 'delete'
  })
}
