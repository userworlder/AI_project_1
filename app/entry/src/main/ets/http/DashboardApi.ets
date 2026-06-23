import { HttpClient } from '../common/HttpClient'
import type { DashboardStats } from '../model/User'

export class DashboardApi {
  static async getStats(context: Context): Promise<DashboardStats> {
    return HttpClient.get<DashboardStats>(context, '/api/dashboard/stats')
  }
}
