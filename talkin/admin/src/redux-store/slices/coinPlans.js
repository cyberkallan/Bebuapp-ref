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


// Async thunks for API calls
export const fetchCoinPlans = createAsyncThunk('coinPlans/fetchCoinPlans', async (params, thunkAPI) => {
  try {
    const { page, pageSize } = params
    
    const response = await axios.get(`${BASE_URL}/api/admin/coinplan/listCoinPlans`, {
      headers: getAuthHeaders(),
      params: {
        page,
        pageSize
      }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createCoinPlan = createAsyncThunk('coinPlans/createCoinPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/coinplan/addCoinPlan`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateCoinPlan = createAsyncThunk('coinPlans/updateCoinPlan', async (payload, thunkAPI) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/coinplan/editCoinPlan`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteCoinPlan = createAsyncThunk('coinPlans/deleteCoinPlan', async (coinPlanId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/coinplan/deleteCoinPlan?coinPlanId=${coinPlanId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, coinPlanId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const toggleCoinPlanField = createAsyncThunk(
  'coinPlans/toggleCoinPlanField',
  async ({ coinPlanId, field }, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/coinplan/toggleCoinPlanField?coinPlanId=${coinPlanId}&field=${field}`,
        {},
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
  initialLoading: true,
  loading: false,
  coinPlans: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const coinPlansSlice = createSlice({
  name: 'coinPlans',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1 // Reset to first page when changing page size
    }
  },
  extraReducers: builder => {
    // Fetch coin plans
    builder.addCase(fetchCoinPlans.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchCoinPlans.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.coinPlans = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchCoinPlans.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create coin plan
    builder.addCase(createCoinPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(createCoinPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.coinPlans = [...state.coinPlans, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Coin Plan created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createCoinPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update coin plan
    builder.addCase(updateCoinPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(updateCoinPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.coinPlans.findIndex(coinPlan => coinPlan._id === action.payload.data._id)

        if (index !== -1) {
          state.coinPlans[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Coin Plan updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateCoinPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete coin plan
    builder.addCase(deleteCoinPlan.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteCoinPlan.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.coinPlans = state.coinPlans.filter(coinPlan => coinPlan._id !== action.payload.coinPlanId)
        state.total -= 1
        toast.success(action.payload.message || 'Coin Plan deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteCoinPlan.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Toggle coin plan field (isActive or isPopular)
    builder.addCase(toggleCoinPlanField.pending, state => {
      state.loading = true
    })
    builder.addCase(toggleCoinPlanField.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.coinPlans.findIndex(coinPlan => coinPlan._id === action.payload.data._id)

        if (index !== -1) {
          state.coinPlans[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Field toggled successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(toggleCoinPlanField.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = coinPlansSlice.actions

export default coinPlansSlice.reducer
