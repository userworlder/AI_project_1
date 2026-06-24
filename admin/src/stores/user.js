import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi } from '@/api/login'

export const useUserStore = defineStore('user', () => {
  // 用户信息
  const userInfo = ref(null)
  
  // Token（从 localStorage 初始化，实现页面刷新后恢复状态）
  const token = ref(localStorage.getItem('admin_token') || null)

  // ========== 计算属性 ==========

  // 判断是否已登录
  const isLoggedIn = computed(() => {
    return !!token.value
  })

  // 判断是否为模拟登录（后端未启动时的回退）
  const isMockLogin = computed(() => {
    return !!token.value && token.value.startsWith('mock_token_')
  })

  // ========== 方法函数 ==========

  // 登录方法
  const login = async (formData) => {
    try {
      // 调用登录接口
      const data = await loginApi(formData)
      
      // 存储 Token 到 state 和 localStorage
      token.value = data.token
      localStorage.setItem('admin_token', data.token)
      
      // 存储用户信息
      userInfo.value = data.user
      localStorage.setItem('admin_user', JSON.stringify(data.user))
      
      return data
    } catch (error) {
      // 如果后端未启动，使用模拟登录
      if (!error.response) {
        const mockToken = `mock_token_${formData.username}_${Date.now()}`
        const mockUser = {
          id: 1,
          username: formData.username,
          nickname: formData.username,
          role: 'admin'
        }
        
        // 存储模拟 Token 和用户信息
        token.value = mockToken
        localStorage.setItem('admin_token', mockToken)
        userInfo.value = mockUser
        localStorage.setItem('admin_user', JSON.stringify(mockUser))
        
        return { token: mockToken, user: mockUser }
      }
      
      throw error
    }
  }

  // 设置用户信息
  const setUserInfo = (info) => {
    userInfo.value = info
    if (info) {
      localStorage.setItem('admin_user', JSON.stringify(info))
    }
  }

  // 退出登录
  const logout = () => {
    userInfo.value = null
    token.value = null
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_user')
  }

  // 初始化：从 localStorage 恢复用户信息
  const initFromStorage = () => {
    const storedUser = localStorage.getItem('admin_user')
    if (storedUser) {
      try {
        userInfo.value = JSON.parse(storedUser)
      } catch (e) {
        console.error('解析用户信息失败:', e)
        localStorage.removeItem('admin_user')
      }
    }
  }

  return {
    userInfo,
    token,
    isLoggedIn,
    isMockLogin,
    login,
    setUserInfo,
    logout,
    initFromStorage
  }
})
