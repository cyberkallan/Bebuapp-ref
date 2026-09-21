import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

// Helper to get auth headers
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

  return {}
}

export const fetchAgencyList = createAsyncThunk('agency/fetchAgencyList', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/agency/fetchAgencyList`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const fetchAgencyRecord = createAsyncThunk(
  'agency/fetchAgencyRecord',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const state = getState()

      // Convert status parameter to appropriate value for API
      let statusParam = params.status || state.agency.status

      if (statusParam === 'active') statusParam = 'true'
      else if (statusParam === 'inactive') statusParam = 'false'
      else if (statusParam === 'all') statusParam = 'All'
      else statusParam = 'All' // Default to 'All'

      // Get date range from params or state
      const startDate = params.startDate || state.agency.startDate || 'All'
      const endDate = params.endDate || state.agency.endDate || 'All'

      const response = await axios.get(`${BASE_URL}/api/admin/agency/fetchAgencyRecord`, {
        headers: getAuthHeaders(),
        params: {
          start: params.page || state.agency.page || 1,
          limit: params.limit || state.agency.pageSize || 10,
          search: params.searchQuery || state.agency.searchQuery || '',
          startDate: startDate,
          endDate: endDate,
          status: statusParam
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const modifyAgencyStatus = createAsyncThunk(
  'agency/modifyAgencyStatus',
  async (agencyId, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/agency/modifyAgencyStatus`,
        {},
        {
          headers: getAuthHeaders(),
          params: { agencyId }
        }
      )

      if (response.data.status) {
        // Removed toast notification here as it's handled in the reducer
        return response.data.data
      } else {
        // Removed toast notification here as it's handled in the reducer
        return rejectWithValue(response.data.message)
      }
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      return rejectWithValue(errorMsg)
    }
  }
)

export const updateAgencyProfile = createAsyncThunk(
  'agency/updateAgencyProfile',
  async ({ agencyId, formData }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/agency/updateAgencyProfile`, formData, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        },
        params: { agencyId }
      })

      if (response.data.status) {
        toast.success(response.data.message || 'Agency updated successfully')

        return response.data.data
      } else {
        toast.error(response.data.message || 'Failed to update agency')

        return rejectWithValue(response.data.message)
      }
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return rejectWithValue(errorMsg)
    }
  }
)

export const fetchUserList = createAsyncThunk('agency/fetchUserList', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/user/fetchUserList`, {
      headers: getAuthHeaders(),
      params: { type: 'real' }
    })

    return response.data
  } catch (error) {
    return rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const registerUserAsAgency = createAsyncThunk(
  'agency/registerUserAsAgency',
  async (formData, { rejectWithValue }) => {
    try {
      const response = await axios.post(`${BASE_URL}/api/admin/agency/registerUserAsAgency`, formData, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        }
      })

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return rejectWithValue(errorMsg)
    }
  }
)

export const fetchAgencyCommissionHistory = createAsyncThunk(
  'agency/fetchAgencyCommissionHistory',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const state = getState()

      const response = await axios.get(`${BASE_URL}/api/admin/history/fetchAgencyCommissionRecords`, {
        headers: getAuthHeaders(),
        params: {
          start: params.start || 1,
          limit: params.limit || 20,
          startDate: params.startDate || 'All',
          endDate: params.endDate || 'All',
          agencyId: params.agencyId
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

const initialState = {
  agencies: [],
  agencyRecords: [],
  total: 0,
  users: [],
  loading: false,
  initialLoad: true,
  page: 1,
  pageSize: 10,
  searchQuery: '',
  startDate: 'All',
  endDate: 'All',
  status: 'all',
  error: null,
  history: [],
  historyTotal: 0,
  historyLoading: false,
  historyInitialLoading: true,
  historyHasMore: true,
  totalCommission: 0
}

const agencySlice = createSlice({
  name: 'agency',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
    },
    setSearchQuery: (state, action) => {
      state.searchQuery = action.payload
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
    },
    setStatus: (state, action) => {
      state.status = action.payload
    },
    resetHistoryPagination: state => {
      state.history = []
      state.historyTotal = 0
      state.historyInitialLoading = true
      state.historyHasMore = true
    }
  },
  extraReducers: builder => {
    builder
      .addCase(fetchAgencyRecord.pending, state => {
        state.loading = true
        state.initialLoad = true
        state.error = null
      })
      .addCase(fetchAgencyRecord.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoad = false

        if (action.payload.status) {
          state.agencyRecords = action.payload.data || []
          state.total = action.payload.total || 0
        } else {
          toast.error(action.payload.message || 'Failed to fetch agencies')
        }
      })
      .addCase(fetchAgencyRecord.rejected, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.error = action.payload
        toast.error(action.payload || 'Failed to fetch agencies')
      })
      .addCase(modifyAgencyStatus.fulfilled, (state, action) => {
        const updatedAgency = action.payload

        // First, update the agency in the records
        state.agencyRecords = state.agencyRecords.map(agency =>
          agency._id === updatedAgency._id ? { ...agency, isActive: updatedAgency.isActive } : agency
        )

        // Then filter out if necessary based on current status filter
        if (state.status === 'active' && !updatedAgency.isActive) {
          state.agencyRecords = state.agencyRecords.filter(agency => agency._id !== updatedAgency._id)
        } else if (state.status === 'inactive' && updatedAgency.isActive) {
          state.agencyRecords = state.agencyRecords.filter(agency => agency._id !== updatedAgency._id)
        }

        // Add toast notification for success
        toast.success('Agency status updated successfully')
      })
      .addCase(updateAgencyProfile.pending, state => {
        state.loading = true
      })
      .addCase(updateAgencyProfile.fulfilled, (state, action) => {
        state.loading = false
        const updatedAgency = action.payload

        state.agencyRecords = state.agencyRecords.map(agency =>
          agency._id === updatedAgency._id ? { ...agency, ...updatedAgency } : agency
        )
      })
      .addCase(updateAgencyProfile.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload || 'Failed to update agency')
      })
      .addCase(fetchUserList.pending, state => {
        state.loading = true
      })
      .addCase(fetchUserList.fulfilled, (state, action) => {
        state.loading = false
        state.users = action.payload.data || []
      })
      .addCase(fetchUserList.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
      .addCase(registerUserAsAgency.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(registerUserAsAgency.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.agencyRecords = [action.payload, ...state.agencyRecords]
          if (state.total) state.total += 1
        } else {
          toast.error(action.payload.message || 'Failed to register agency')
        }
      })
      .addCase(registerUserAsAgency.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload || 'Failed to register agency')
      })
      .addCase(fetchAgencyCommissionHistory.pending, (state, action) => {
        state.historyLoading = true

        if (action.meta.arg.start === 1 || !action.meta.arg.start) {
          state.historyInitialLoading = true
        }
      })
      .addCase(fetchAgencyCommissionHistory.fulfilled, (state, action) => {
        state.historyLoading = false
        state.historyInitialLoading = false

        if (action.payload.status) {
          if (action.meta.arg.start && action.meta.arg.start > 1) {
            state.history = [...state.history, ...action.payload.data]
          } else {
            state.history = action.payload.data || []
          }

          state.historyTotal = action.payload.total || 0

          state.historyHasMore = state.history.length < state.historyTotal

          state.totalCommission = state.history.reduce((sum, item) => sum + (item.coin || 0), 0)
        } else {
          toast.error(action.payload.message || 'Failed to fetch commission history')
        }
      })
      .addCase(fetchAgencyCommissionHistory.rejected, (state, action) => {
        state.historyLoading = false
        state.historyInitialLoading = false
        state.error = action.payload
        toast.error(action.payload || 'Failed to fetch commission history')
      })
  }
})

export const { setPage, setPageSize, setSearchQuery, setDateRange, setStatus, resetHistoryPagination } =
  agencySlice.actions

export default agencySlice.reducer
