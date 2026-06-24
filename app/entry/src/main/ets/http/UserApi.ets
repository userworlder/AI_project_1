import { HttpClient } from '../common/HttpClient'
import type { UserInfo, UpdateUserRequest, ChangePasswordRequest } from '../model/User'

/**
 * 用户相关 API
 */
export class UserApi {
  /**
   * 获取当前登录用户信息
   * @param context 上下文
   */
  static async getMe(context: Context): Promise<UserInfo> {
    return HttpClient.get<UserInfo>(context, '/api/users/me')
  }

  /**
   * 更新用户信息
   * @param context 上下文
   * @param id 用户 ID
   * @param data 更新数据
   */
  static async updateUser(context: Context, id: number, data: UpdateUserRequest): Promise<UserInfo> {
    return HttpClient.put<UserInfo>(context, `/api/users/${id}`, data)
  }

  /**
   * 修改密码
   * @param context 上下文
   * @param data 密码数据（旧密码 + 新密码）
   */
  static async changePassword(context: Context, data: ChangePasswordRequest): Promise<void> {
    await HttpClient.put<void>(context, '/api/users/me/password', data)
  }
}
