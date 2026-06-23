import http from '@ohos.net.http'
import { Constants } from './Constants'
import { TokenUtil } from './TokenUtil'

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export class HttpClient {
  private static async getRequest(context: Context): Promise<http.HttpRequest> {
    const request = http.createHttp()
    return request
  }

  static async request<T>(
    context: Context,
    method: 'GET' | 'POST' | 'PUT' | 'DELETE',
    url: string,
    data?: object
  ): Promise<T> {
    const request = await HttpClient.getRequest(context)
    const token = await TokenUtil.getToken(context)
    const fullUrl = `${Constants.BASE_URL}${url}`

    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }

    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    console.info(`[HttpClient] 请求开始: ${method} ${fullUrl}`)
    console.info(`[HttpClient] 请求头: ${JSON.stringify(headers)}`)
    if (data) {
      console.info(`[HttpClient] 请求体: ${JSON.stringify(data)}`)
    }

    try {
      const response = await request.request(fullUrl, {
        method: http.RequestMethod[method],
        header: headers,
        extraData: data ? JSON.stringify(data) : undefined,
        connectTimeout: 10000,
        readTimeout: 10000
      })

      console.info(`[HttpClient] 响应状态码: ${response.responseCode}`)
      console.info(`[HttpClient] 响应头: ${JSON.stringify(response.header)}`)
      console.info(`[HttpClient] 响应体: ${response.result.toString()}`)

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result.toString()) as ApiResponse<T>
        if (result.code === 200) {
          console.info(`[HttpClient] 请求成功: ${JSON.stringify(result.data)}`)
          return result.data
        } else {
          console.error(`[HttpClient] 业务错误: code=${result.code}, message=${result.message}`)
          throw new Error(result.message || '请求失败')
        }
      } else if (response.responseCode === 401) {
        await TokenUtil.clearAll(context)
        throw new Error('登录已过期，请重新登录')
      } else {
        throw new Error(`请求失败，状态码：${response.responseCode}`)
      }
    } catch (error) {
      console.error(`[HttpClient] 请求异常: ${(error as Error).message}`)
      throw new Error((error as Error).message || '请求异常')
    } finally {
      request.destroy()
    }
  }

  static async get<T>(context: Context, url: string): Promise<T> {
    return HttpClient.request<T>(context, 'GET', url)
  }

  static async post<T>(context: Context, url: string, data?: object): Promise<T> {
    return HttpClient.request<T>(context, 'POST', url, data)
  }

  static async put<T>(context: Context, url: string, data?: object): Promise<T> {
    return HttpClient.request<T>(context, 'PUT', url, data)
  }

  static async del<T>(context: Context, url: string): Promise<T> {
    return HttpClient.request<T>(context, 'DELETE', url)
  }
}
