export interface LoginRequest {
  username: string
  password: string
}

export interface RegisterRequest {
  username: string
  password: string
  confirmPassword: string
  nickname?: string
  email?: string
  phone?: string
}

export interface RegisterBody {
  username: string
  password: string
  nickname: string
  email: string
  phone: string
}

export interface LoginResponse {
  token: string
  user: UserInfo
}

export interface UserInfo {
  id: number
  username: string
  nickname?: string
  email?: string
  phone?: string
  avatar?: string
  role?: string
  status?: number
  createTime?: string
}

export interface RememberedAccount {
  username: string
  password: string
}

export interface DashboardStats {
  totalUsers: number
  totalLearningHours: number
  aiInteractions: number
  activeUsers: number
}

export interface StudyRecordItem {
  id: number
  userId: number
  content: string
  duration: number
  type: string
  status: number
  createTime: string
}

export interface UpdateUserRequest {
  nickname?: string
  email?: string
  phone?: string
  avatar?: string
}

export interface ChangePasswordRequest {
  oldPassword: string
  newPassword: string
}

export interface CreateStudyRecordRequest {
  userId: number
  content: string
  duration: number
  type: string
}
