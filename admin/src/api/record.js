import request from '@/utils/request'

const BASE = '/study-records'

export const getRecordList = (params) => {
  return request({
    url: `${BASE}/list`,
    method: 'get',
    params: {
      current: params?.current || params?.page || 1,
      size: params?.size || params?.pageSize || 10
    }
  })
}

export const getRecordById = (id) => {
  return request({
    url: `${BASE}/${id}`,
    method: 'get'
  })
}

export const createRecord = (data) => {
  return request({
    url: BASE,
    method: 'post',
    data
  })
}

export const updateRecord = (id, data) => {
  return request({
    url: `${BASE}/${id}`,
    method: 'put',
    data
  })
}

export const deleteRecord = (id) => {
  return request({
    url: `${BASE}/${id}`,
    method: 'delete'
  })
}
