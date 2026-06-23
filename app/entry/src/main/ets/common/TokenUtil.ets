import preferences from '@ohos.data.preferences'
import { Constants } from './Constants'
import type { UserInfo, RememberedAccount } from '../model/User'

export class TokenUtil {
  private static PREFERENCES_NAME = 'app_prefs'

  static async getPreferences(context: Context): Promise<preferences.Preferences> {
    return preferences.getPreferences(context, TokenUtil.PREFERENCES_NAME)
  }

  static async saveToken(context: Context, token: string): Promise<void> {
    const prefs = await TokenUtil.getPreferences(context)
    await prefs.put(Constants.STORAGE_KEYS.TOKEN, token)
    await prefs.flush()
  }

  static async getToken(context: Context): Promise<string | undefined> {
    const prefs = await TokenUtil.getPreferences(context)
    const token = await prefs.get(Constants.STORAGE_KEYS.TOKEN, '')
    return token as string || undefined
  }

  static async saveUserInfo(context: Context, userInfo: UserInfo): Promise<void> {
    const prefs = await TokenUtil.getPreferences(context)
    await prefs.put(Constants.STORAGE_KEYS.USER_INFO, JSON.stringify(userInfo))
    await prefs.flush()
  }

  static async getUserInfo(context: Context): Promise<UserInfo | undefined> {
    const prefs = await TokenUtil.getPreferences(context)
    const userInfoStr = await prefs.get(Constants.STORAGE_KEYS.USER_INFO, '')
    if (userInfoStr) {
      return JSON.parse(userInfoStr as string) as UserInfo
    }
    return undefined
  }

  static async saveRememberedAccount(context: Context, username: string, password: string): Promise<void> {
    const prefs = await TokenUtil.getPreferences(context)
    const account: RememberedAccount = { username, password }
    await prefs.put(Constants.STORAGE_KEYS.REMEMBERED_ACCOUNT, JSON.stringify(account))
    await prefs.flush()
  }

  static async getRememberedAccount(context: Context): Promise<RememberedAccount | undefined> {
    const prefs = await TokenUtil.getPreferences(context)
    const accountStr = await prefs.get(Constants.STORAGE_KEYS.REMEMBERED_ACCOUNT, '')
    if (accountStr) {
      return JSON.parse(accountStr as string) as RememberedAccount
    }
    return undefined
  }

  static async clearAll(context: Context): Promise<void> {
    const prefs = await TokenUtil.getPreferences(context)
    await prefs.delete(Constants.STORAGE_KEYS.TOKEN)
    await prefs.delete(Constants.STORAGE_KEYS.USER_INFO)
    await prefs.flush()
  }

  static async getUsername(context: Context): Promise<string | undefined> {
    const userInfo = await TokenUtil.getUserInfo(context)
    return userInfo?.username
  }
}
