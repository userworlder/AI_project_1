import request from '@/utils/request'

export const login = (data) => {
  console.log('Login data being sent:', data)
  return request({
    url: '/admin/login',
    method: 'post',
    data
  })
}

export const getInfo = () => {
  return request({
    url: '/admin/info',
    method: 'get'
  })
}
