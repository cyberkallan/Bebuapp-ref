
import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'

import { baseURL, secretKey } from '@/config'

const BASE_URL = baseURL


const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    return {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }
  }
}

// Async thunks for API calls
export const getDashboardMetrics = createAsyncThunk(
  'dashboard/getAdminDashboardStats',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getAdminDashboardStats?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch dashboard metrics')
    }
  }
)

export const getRecentUsers = createAsyncThunk(
  'dashboard/getLatestUsers',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getLatestUsers?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch recent users')
    }
  }
)

export const getTopContributors = createAsyncThunk(
  'dashboard/getTopContributorsList',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getTopContributorsList?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch top contributors')
    }
  }
)

export const getTopPerformanceListeners = createAsyncThunk(
  'dashboard/getTopPerformingListeners',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getTopPerformingListeners?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch top likers')
    }
  }
)

export const getGraphStats = createAsyncThunk(
  'dashboard/fetchChartMetrics',
  async ({ startDate = 'All', endDate = 'All', type }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/fetchChartMetrics?startDate=${startDate}&endDate=${endDate}&type=${type}`,
        {
          headers: getAuthHeaders()
        }
      )

      let data

      // Handle based on type
      if (type === 'user') {
        data = response.data.chartUser
      } else if (type === 'listener') {
        data = response.data.chartListener
      }

      return { type, data }
    } catch (error) {
      return rejectWithValue({
        type,
        message: error.response?.data?.message || `Failed to fetch ${type} graph stats`
      })
    }
  }
)

export const getTopHosts = createAsyncThunk(
  'dashboard/getTopHosts',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getHighestEarningHosts?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch top hosts')
    }
  }
)

export const getTopAgencies = createAsyncThunk(
  'dashboard/getTopAgencies',
  async ({ startDate = 'All', endDate = 'All' }, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/dashboard/getHighestPerformingAgencies?startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch top agencies')
    }
  }
)

export const getReportedUsers = createAsyncThunk('dashboard/getReportedUsers', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/dashboard/fetchReportedProfiles`, {
      headers: getAuthHeaders()
    })

    return response.data.data
  } catch (error) {
    return rejectWithValue(error.response?.data?.message || 'Failed to fetch reported users')
  }
})

export const getBlockedUsers = createAsyncThunk('dashboard/getBlockedUsers', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/dashboard/fetchBlockedUsers`, {
      headers: getAuthHeaders()
    })

    return response.data.data
  } catch (error) {
    return rejectWithValue(error.response?.data?.message || 'Failed to fetch blocked users')
  }
})

const initialState = {
  metrics: {
    totalUsers: 0,
    totalBlockedUsers: 0,
    totalPendingListeners: 0,
    totalListeners: 0,
    totalTalkTopics: 0,
    totalPendingWithdrawalRecord: 0
  },
  recentUsers: [],
  topContributors: [],
  topPerformanceListeners: [],
  reportedUsers: [],
  blockedUsers: [],
  topHosts: [],
  topAgencies: [],
  graphStats: {
    listener: [],
    user: []
  },
  loading: {
    metrics: true,
    recentUsers: true,
    topContributors: true,
    reportedUsers: true,
    blockedUsers: true,
    topPerformanceListeners: true,
    topHosts: true,
    topAgencies: true,
    graphStats: {
      listener: [],
      user: []
    }
  },
  error: {
    metrics: null,
    recentUsers: null,
    topContributors: null,
    reportedUsers: null,
    blockedUsers: null,
    topPerformanceListeners: null,
    topHosts: null,
    topAgencies: null,
    graphStats: {
      listener: [],
      user: []
    }
  }
}

const dashboardSlice = createSlice({
  name: 'dashboard',
  initialState,
  reducers: {
    clearErrors: state => {
      state.error = {
        metrics: null,
        recentUsers: null,
        topContributors: null,
        reportedUsers: null,
        blockedUsers: null,
        topPerformanceListeners: null,
        topHosts: null,
        topAgencies: null,
        graphStats: {
          video: null,
          post: null,
          user: null
        }
      }
    }
  },
  extraReducers: builder => {
    // Dashboard Metrics
    builder
      .addCase(getDashboardMetrics.pending, state => {
        state.loading.metrics = true
        state.error.metrics = null
      })
      .addCase(getDashboardMetrics.fulfilled, (state, action) => {
        state.loading.metrics = false
        state.metrics = action.payload
      })
      .addCase(getDashboardMetrics.rejected, (state, action) => {
        state.loading.metrics = false
        state.error.metrics = action.payload || 'Error fetching metrics'
      })

    // Recent Users
    builder
      .addCase(getRecentUsers.pending, state => {
        state.loading.recentUsers = true
        state.error.recentUsers = null
      })
      .addCase(getRecentUsers.fulfilled, (state, action) => {
        state.loading.recentUsers = false
        state.recentUsers = action.payload
      })
      .addCase(getRecentUsers.rejected, (state, action) => {
        state.loading.recentUsers = false
        state.error.recentUsers = action.payload || 'Error fetching recent users'
      })

    // Top Contributors
    builder
      .addCase(getTopContributors.pending, state => {
        state.loading.topContributors = true
        state.error.topContributors = null
      })
      .addCase(getTopContributors.fulfilled, (state, action) => {
        state.loading.topContributors = false
        state.topContributors = action.payload
      })
      .addCase(getTopContributors.rejected, (state, action) => {
        state.loading.topContributors = false
        state.error.topContributors = action.payload || 'Error fetching top contributors'
      })

    // Top Likers
    builder
      .addCase(getTopPerformanceListeners.pending, state => {
        state.loading.topPerformanceListeners = true
        state.error.topPerformanceListeners = null
      })
      .addCase(getTopPerformanceListeners.fulfilled, (state, action) => {
        state.loading.topPerformanceListeners = false
        state.topPerformanceListeners = action.payload
      })
      .addCase(getTopPerformanceListeners.rejected, (state, action) => {
        state.loading.topPerformanceListeners = false
        state.error.topPerformanceListeners = action.payload || 'Error fetching top likers'
      })

    // Top Hosts
    builder
      .addCase(getTopHosts.pending, state => {
        state.loading.topHosts = true
        state.error.topHosts = null
      })
      .addCase(getTopHosts.fulfilled, (state, action) => {
        state.loading.topHosts = false
        state.topHosts = action.payload
      })
      .addCase(getTopHosts.rejected, (state, action) => {
        state.loading.topHosts = false
        state.error.topHosts = action.payload || 'Error fetching top hosts'
      })

    // Top Agencies
    builder
      .addCase(getTopAgencies.pending, state => {
        state.loading.topAgencies = true
        state.error.topAgencies = null
      })
      .addCase(getTopAgencies.fulfilled, (state, action) => {
        state.loading.topAgencies = false
        state.topAgencies = action.payload
      })
      .addCase(getTopAgencies.rejected, (state, action) => {
        state.loading.topAgencies = false
        state.error.topAgencies = action.payload || 'Error fetching top agencies'
      })

    // Graph Stats
    builder
      .addCase(getGraphStats.pending, (state, action) => {
        const type = action.meta.arg.type

        state.loading.graphStats[type] = true
        state.error.graphStats[type] = null
      })
      .addCase(getGraphStats.fulfilled, (state, action) => {
        const type = action.payload.type
        const data = action.payload.data

        state.loading.graphStats[type] = false
        state.graphStats[type] = Array.isArray(data) ? data : []
      })
      .addCase(getGraphStats.rejected, (state, action) => {
        const type = action.payload?.type || action.meta.arg.type

        state.loading.graphStats[type] = false
        state.error.graphStats[type] = action.payload?.message || `Error fetching ${type} stats`
      })

    // Reported Users
    builder
      .addCase(getReportedUsers.pending, state => {
        state.loading.reportedUsers = true
        state.error.reportedUsers = null
      })
      .addCase(getReportedUsers.fulfilled, (state, action) => {
        state.loading.reportedUsers = false
        state.reportedUsers = action.payload
      })
      .addCase(getReportedUsers.rejected, (state, action) => {
        state.loading.reportedUsers = false
        state.error.reportedUsers = action.payload || 'Error fetching reported users'
      })

    // Blocked Users
    builder
      .addCase(getBlockedUsers.pending, state => {
        state.loading.blockedUsers = true
        state.error.blockedUsers = null
      })
      .addCase(getBlockedUsers.fulfilled, (state, action) => {
        state.loading.blockedUsers = false
        state.blockedUsers = action.payload
      })
      .addCase(getBlockedUsers.rejected, (state, action) => {
        state.loading.blockedUsers = false
        state.error.blockedUsers = action.payload || 'Error fetching blocked users'
      })
  }
})

export const { clearErrors } = dashboardSlice.actions
export default dashboardSlice.reducer
