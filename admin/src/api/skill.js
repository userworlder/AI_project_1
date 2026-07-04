import request from '@/utils/request'
import { mockSkillList } from '@/mock/skill'

export const getSkillList = (params) => {
  return request({
    url: '/skills',
    method: 'get',
    params
  })
}

// 将技能列表转换为树形结构
const convertToTree = (list) => {
  const categoryMap = {}
  
  // 按分类分组
  list.forEach(item => {
    if (!categoryMap[item.category]) {
      categoryMap[item.category] = []
    }
    categoryMap[item.category].push(item)
  })
  
  // 转换为树形结构
  return Object.keys(categoryMap).map(category => ({
    id: category,
    label: category,
    name: category,
    children: categoryMap[category].map(skill => ({
      id: skill.id,
      label: skill.name,
      name: skill.name,
      level: skill.level,
      description: skill.description,
      createdAt: skill.createTime,
      category: skill.category
    }))
  }))
}

// 获取全量技能树
export const getSkillTree = () => {
  return request({
    url: '/skills/tree',
    method: 'get'
  }).catch(() => {
    // Mock数据兜底
    return convertToTree(mockSkillList)
  })
}

// 按分类获取技能树
export const getSkillTreeByCategory = (category) => {
  return request({
    url: '/skills/tree',
    method: 'get',
    params: { category }
  }).catch(() => {
    // Mock数据兜底
    const filteredList = mockSkillList.filter(item => item.category === category)
    return convertToTree(filteredList)
  })
}

export const getSkillById = (id) => {
  return request({
    url: `/skills/${id}`,
    method: 'get'
  })
}

export const createSkill = (data) => {
  return request({
    url: '/skills',
    method: 'post',
    data
  })
}

export const updateSkill = (id, data) => {
  return request({
    url: `/skills/${id}`,
    method: 'put',
    data
  })
}

export const deleteSkill = (id) => {
  return request({
    url: `/skills/${id}`,
    method: 'delete'
  })
}
