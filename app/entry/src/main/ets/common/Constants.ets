export interface StorageKeys {
  TOKEN: string
  USER_INFO: string
  REMEMBERED_ACCOUNT: string
}

export class Constants {
  static BASE_URL: string = 'http://10.0.2.2:8080'

  static STORAGE_KEYS: StorageKeys = {
    TOKEN: 'token',
    USER_INFO: 'user_info',
    REMEMBERED_ACCOUNT: 'remembered_account'
  }
}
