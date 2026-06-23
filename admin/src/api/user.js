import request from '@/utils/request'

/** 转换后端分页格式 -> 前端分页格式 */
const transformPageResult = (data) => {
  if (!data) return { list: [], total: 0, page: 1, pageSize: 10 }
  return {
    list: data.records || data.list || [],
    total: data.total || 0,
    page: data.current || data.page || 1,
    pageSize: data.size || data.pageSize || 10
  }
}

// ========== Mock 数据兜底 ==========
const mockUserList = [
  { id: 1, username: 'admin', nickname: '管理员', email: 'admin@example.com', role: 'admin', status: 1, createTime: '2024-01-01 10:00:00' },
  { id: 2, username: 'teacher1', nickname: '张老师', email: 'teacher1@example.com', role: 'teacher', status: 1, createTime: '2024-01-02 11:00:00' },
  { id: 3, username: 'student1', nickname: '小明', email: 'student1@example.com', role: 'student', status: 1, createTime: '2024-01-04 13:00:00' }
]

// ========== 接口函数 ==========

export const getUserList = async (params) => {
  try {
    const response = await request({
      url: '/users',
      method: 'get',
      params: {
        current: params?.page || 1,
        size: params?.pageSize || 10,
        keyword: params?.keyword || undefined
      }
    })
    return transformPageResult(response)
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    let filteredList = [...mockUserList]
    if (params?.keyword) {
      const kw = params.keyword.toLowerCase()
      filteredList = filteredList.filter(item =>
        item.username.toLowerCase().includes(kw) ||
        item.nickname.toLowerCase().includes(kw) ||
        (item.email && item.email.toLowerCase().includes(kw))
      )
    }
    const page = params?.page || 1
    const pageSize = params?.pageSize || 10
    const start = (page - 1) * pageSize
    return {
      list: filteredList.slice(start, start + pageSize),
      total: filteredList.length,
      page,
      pageSize
    }
  }
}

export const getUserById = async (id) => {
  try {
    const response = await request({
      url: `/users/${id}`,
      method: 'get'
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    const user = mockUserList.find(item => item.id === Number(id))
    if (!user) throw new Error('用户不存在')
    return user
  }
}

export const createUser = async (data) => {
  try {
    const response = await request({
      url: '/users/register',
      method: 'post',
      data
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    const newUser = {
      id: Date.now(), ...data,
      status: 1,
      createTime: new Date().toISOString().replace('T', ' ').substring(0, 19)
    }
    mockUserList.unshift(newUser)
    return newUser
  }
}

export const updateUser = async (id, data) => {
  try {
    const response = await request({
      url: `/users/${id}`,
      method: 'put',
      data
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    const index = mockUserList.findIndex(item => item.id === Number(id))
    if (index === -1) throw new Error('用户不存在')
    mockUserList[index] = { ...mockUserList[index], ...data }
    return mockUserList[index]
  }
}

export const deleteUser = async (id) => {
  try {
    const response = await request({
      url: `/users/${id}`,
      method: 'delete'
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    const index = mockUserList.findIndex(item => item.id === Number(id))
    if (index === -1) throw new Error('用户不存在')
    mockUserList.splice(index, 1)
    return { success: true }
  }
}