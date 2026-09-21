import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

// Helper to get auth headers
const getAuthHeaders = (options = {}) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    const headers = {
      key: secretKey,
      Authorization: token ? `Bearer ${token}` : '',
      'x-admin-uid': uid
    }

    // Only add Content-Type if not explicitly omitted
    // This allows for multipart/form-data uploads
    if (!options.omitContentType) {
      headers['Content-Type'] = 'application/json'
    }

    return headers
  }

  return {}
}

// Async thunks for API calls
export const fetchPaymentOptions = createAsyncThunk(
  'paymentOptions/fetchPaymentOptions',
  async (params = {}, thunkAPI) => {
    try {
      const { page, pageSize } = params

      const response = await axios.get(`${BASE_URL}/api/admin/paymentOption/getAllPaymentOptions`, {
        headers: getAuthHeaders(),
        params: {
          page,
          limit: pageSize
        }
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const createPaymentOption = createAsyncThunk(
  'paymentOptions/createPaymentOption',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.post(`${BASE_URL}/api/admin/paymentOption/createPaymentOption`, formData, {
        headers: getAuthHeaders({ omitContentType: true }) // Remove Content-Type for FormData
      })
      
      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const updatePaymentOption = createAsyncThunk(
  'paymentOptions/updatePaymentOption',
  async (formData, thunkAPI) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/paymentOption/updatePaymentOption`, formData, {
        headers: getAuthHeaders({ omitContentType: true }) // Remove Content-Type for FormData
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const deletePaymentOption = createAsyncThunk(
  'paymentOptions/deletePaymentOption',
  async (paymentOptionId, thunkAPI) => {
    try {
      const response = await axios.delete(
        `${BASE_URL}/api/admin/paymentOption/deletePaymentOption?paymentOptionId=${paymentOptionId}`,
        {
          headers: getAuthHeaders()
        }
      )

      return { ...response.data, paymentOptionId }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

export const togglePaymentOptionStatus = createAsyncThunk(
  'paymentOptions/togglePaymentOptionStatus',
  async (paymentOptionId, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/paymentOption/togglePaymentOptionStatus?paymentOptionId=${paymentOptionId}`,
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
  paymentOptions: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const paymentOptionsSlice = createSlice({
  name: 'paymentOptions',
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
    // Fetch payment options
    builder.addCase(fetchPaymentOptions.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchPaymentOptions.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.paymentOptions = action.payload.data
        state.total = action.payload.total
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchPaymentOptions.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create payment option
    builder.addCase(createPaymentOption.pending, state => {
      state.loading = true
    })
    builder.addCase(createPaymentOption.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.paymentOptions = [...state.paymentOptions, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Payment option created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createPaymentOption.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update payment option
    builder.addCase(updatePaymentOption.pending, state => {
      state.loading = true
    })
    builder.addCase(updatePaymentOption.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.paymentOptions.findIndex(option => option._id === action.payload.data._id)

        if (index !== -1) {
          state.paymentOptions[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Payment option updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updatePaymentOption.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete payment option
    builder.addCase(deletePaymentOption.pending, state => {
      state.loading = true
    })
    builder.addCase(deletePaymentOption.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.paymentOptions = state.paymentOptions.filter(option => option._id !== action.payload.paymentOptionId)
        state.total -= 1
        toast.success(action.payload.message || 'Payment option deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deletePaymentOption.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Toggle payment option status
    builder.addCase(togglePaymentOptionStatus.pending, state => {
      state.loading = true
    })
    builder.addCase(togglePaymentOptionStatus.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.paymentOptions.findIndex(option => option._id === action.payload.data._id)

        if (index !== -1) {
          state.paymentOptions[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Status toggled successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(togglePaymentOptionStatus.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = paymentOptionsSlice.actions

export default paymentOptionsSlice.reducer
