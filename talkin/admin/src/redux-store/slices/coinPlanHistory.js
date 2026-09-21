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

// Fetch coin plan history
export const fetchCoinPlanHistory = createAsyncThunk(
  'coinPlanHistory/fetchCoinPlanHistory',
  async ({ page = 1, limit = 10, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/coinplan/getCoinPurchaseHistory?start=${page}&limit=${limit}&startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

const initialState = {
  loading: false,
  history: [],
  adminEarnings: 0,
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0,
  dateRange: {
    startDate: 'All',
    endDate: 'All'
  }
}

const coinPlanHistorySlice = createSlice({
  name: 'coinPlanHistory',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1 // Reset to first page when changing page size
    },
    setDateRange: (state, action) => {
      state.dateRange = action.payload
      state.page = 1 // Reset to first page when changing date range
    }
  },
  extraReducers: builder => {
    // Fetch coin plan history
    builder.addCase(fetchCoinPlanHistory.pending, state => {
      state.loading = true
    })
    builder.addCase(fetchCoinPlanHistory.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.history = action.payload.data
        state.total = action.payload.total || 0
        state.adminEarnings = action.payload.adminEarnings || 0
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchCoinPlanHistory.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize, setDateRange } = coinPlanHistorySlice.actions

export default coinPlanHistorySlice.reducer
