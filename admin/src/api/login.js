import request from '@/utils/request'

export const login = (data) => {
  console.log('Login data being sent:', data)
  return request({
    url: '/auth/admin/login',
    method: 'post',
    data
  })
}

export const register = (data) => {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

export const getInfo = () => {
  return request({
    url: '/users/me',
    method: 'get'
  })
}
