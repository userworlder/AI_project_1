import { HttpClient } from '../common/HttpClient'
import type { LoginRequest, RegisterRequest, LoginResponse } from '../model/User'

export class AuthApi {
  static async login(context: Context, data: LoginRequest): Promise<LoginResponse> {
    return HttpClient.post<LoginResponse>(context, '/api/auth/admin/login', data)
  }

  static async register(context: Context, data: RegisterRequest): Promise<void> {
    await HttpClient.post<void>(context, '/api/auth/register', {
      username: data.username,
      password: data.password,
      nickname: data.nickname || data.username,
      email: data.email || '',
      phone: data.phone || ''
    })
  }
}
