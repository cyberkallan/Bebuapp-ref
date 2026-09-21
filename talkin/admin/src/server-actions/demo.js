'use server'

import axios from 'axios'

import { baseURL, secretKey } from '@/config'

export const getDashboardState = async (headers, params = {}, data) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/dashboard/getAdminDashboardStats`, {
      headers: { ...headers, key: secretKey },
      params: {
        startDate: params.startDate,
        endDate: params.endDate
      }
    })

    return response.data
  } catch (error) {
    console.log('Error--->', error)
  }
}

export const getRecentUser = async (headers, params = {}, data) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/dashboard/getLatestUsers`, {
      headers: { ...headers, key: secretKey },
      params: {
        startDate: params.startDate,
        endDate: params.endDate
      }
    })

    return response.data
  } catch (error) {
    console.log('Error--->', error)
  }
}

export const getTopContributors = async (headers, params = {}, data) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/dashboard/getTopContributorsList`, {
      headers: { ...headers, key: secretKey },
      params: {
        startDate: params.startDate,
        endDate: params.endDate
      }
    })

    return response.data
  } catch (error) {
    console.log('Error--->', error)
  }
}

export const getTopPerformanceListeners = async (headers, params = {}, data) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/dashboard/getTopPerformingListeners`, {
      headers: { ...headers, key: secretKey },
      params: {
        startDate: params.startDate,
        endDate: params.endDate
      }
    })

    return response.data
  } catch (error) {
    console.log('Error--->', error)
  }
}

export const getGraphStats = async (headers, params = {}, data) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/dashboard/fetchChartMetrics`, {
      headers: { ...headers, key: secretKey },
      params: {
        startDate: params.startDate,
        endDate: params.endDate,
        type: params.type
      }
    })
    
    return response.data
  } catch (error) {
    console.log('Error--->', error)
  }
}
