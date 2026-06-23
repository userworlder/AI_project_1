/**
 * Token 工具函数
 * 统一管理 localStorage 中的 Token 读写操作
 */

// Token 存储的 key
const TOKEN_KEY = 'admin_token'
const USER_KEY = 'admin_user'

/**
 * 获取 Token
 * @returns {string|null} 存储的 token 值
 */
export const getToken = () => {
  return localStorage.getItem(TOKEN_KEY)
}

/**
 * 设置 Token
 * @param {string} token - 要存储的 token 值
 */
export const setToken = (token) => {
  localStorage.setItem(TOKEN_KEY, token)
}

/**
 * 移除 Token
 */
export const removeToken = () => {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

/**
 * 获取用户信息
 * @returns {object|null} 存储的用户信息
 */
export const getUser = () => {
  const userStr = localStorage.getItem(USER_KEY)
  return userStr ? JSON.parse(userStr) : null
}

/**
 * 设置用户信息
 * @param {object} user - 用户信息对象
 */
export const setUser = (user) => {
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}

export default {
  getToken,
  setToken,
  removeToken,
  getUser,
  setUser
}
