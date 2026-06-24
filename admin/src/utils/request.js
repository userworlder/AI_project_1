import axios from 'axios'
import { getToken } from '@/utils/token'
import { ElMessage } from 'element-plus'

const service = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// ========== 请求拦截器 ==========
service.interceptors.request.use(
  config => {
    // 从 token 工具函数获取 Token
    const token = getToken()

    console.log('Request URL:', config.url)
    console.log('Token exists:', !!token)

    // 如果有 Token，添加到请求头
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
      console.log('Authorization header added')
    }

    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// ========== 响应拦截器 ==========
service.interceptors.response.use(
  response => {
    const res = response.data

    // 业务状态码非 200 视为错误
    if (res.code !== 200) {
      return Promise.reject(new Error(res.message || '请求失败'))
    }

    return res.data
  },
  error => {
    console.error('响应错误:', error)

    // 401 未授权 - Token 过期或无效
    if (error.response && error.response.status === 401) {
      // 只清除 Token 但不强跳，让路由守卫和组件自行处理
      import('@/utils/token').then(({ removeToken }) => {
        removeToken()
      })
    }

    return Promise.reject(error)
  }
)

export default service
