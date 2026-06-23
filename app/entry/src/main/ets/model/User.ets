export interface LoginRequest {
  username: string
  password: string
}

export interface RegisterRequest {
  username: string
  password: string
  confirmPassword: string
  phone: string
}

export interface LoginResponse {
  token: string
  user: UserInfo
}

export interface UserInfo {
  id: number
  username: string
  phone: string
  job?: string
  introduction?: string
}

export interface RememberedAccount {
  username: string
  password: string
}
