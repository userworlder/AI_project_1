import request from '@/utils/request'

// ========== Mock 数据 ==========
const mockUserList = [
  { id: 1, username: 'admin', nickname: '管理员', email: 'admin@example.com', role: 'admin', createdAt: '2024-01-01 10:00:00' },
  { id: 2, username: 'teacher1', nickname: '张老师', email: 'teacher1@example.com', role: 'teacher', createdAt: '2024-01-02 11:00:00' },
  { id: 3, username: 'teacher2', nickname: '李老师', email: 'teacher2@example.com', role: 'teacher', createdAt: '2024-01-03 12:00:00' },
  { id: 4, username: 'student1', nickname: '小明', email: 'student1@example.com', role: 'student', createdAt: '2024-01-04 13:00:00' },
  { id: 5, username: 'student2', nickname: '小红', email: 'student2@example.com', role: 'student', createdAt: '2024-01-05 14:00:00' },
  { id: 6, username: 'student3', nickname: '小刚', email: 'student3@example.com', role: 'student', createdAt: '2024-01-06 15:00:00' },
  { id: 7, username: 'student4', nickname: '小丽', email: 'student4@example.com', role: 'student', createdAt: '2024-01-07 16:00:00' },
  { id: 8, username: 'student5', nickname: '小华', email: 'student5@example.com', role: 'student', createdAt: '2024-01-08 17:00:00' },
  { id: 9, username: 'student6', nickname: '小强', email: 'student6@example.com', role: 'student', createdAt: '2024-01-09 18:00:00' },
  { id: 10, username: 'student7', nickname: '小芳', email: 'student7@example.com', role: 'student', createdAt: '2024-01-10 19:00:00' },
  { id: 11, username: 'student8', nickname: '小军', email: 'student8@example.com', role: 'student', createdAt: '2024-01-11 20:00:00' },
  { id: 12, username: 'student9', nickname: '小梅', email: 'student9@example.com', role: 'student', createdAt: '2024-01-12 21:00:00' }
]

// ========== 接口函数 ==========

export const getUserList = async (params) => {
  try {
    const response = await request({
      url: '/users',
      method: 'get',
      params
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    // Mock 数据兜底：前端分页和搜索
    let filteredList = [...mockUserList]

    // 搜索过滤
    if (params?.keyword) {
      const keyword = params.keyword.toLowerCase()
      filteredList = filteredList.filter(item =>
        item.username.toLowerCase().includes(keyword) ||
        item.nickname.toLowerCase().includes(keyword) ||
        item.email.toLowerCase().includes(keyword)
      )
    }

    // 分页
    const page = params?.page || 1
    const pageSize = params?.pageSize || 10
    const start = (page - 1) * pageSize
    const end = start + pageSize
    const list = filteredList.slice(start, end)

    return {
      list,
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
    if (!user) {
      throw new Error('用户不存在')
    }
    return user
  }
}

export const createUser = async (data) => {
  try {
    const response = await request({
      url: '/users',
      method: 'post',
      data
    })
    return response
  } catch (error) {
    console.warn('接口调用失败，使用 Mock 数据兜底:', error)
    const newUser = {
      id: Date.now(),
      ...data,
      createdAt: new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      }).replace(/\//g, '-')
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
    if (index === -1) {
      throw new Error('用户不存在')
    }
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
    if (index === -1) {
      throw new Error('用户不存在')
    }
    mockUserList.splice(index, 1)
    return { success: true }
  }
}