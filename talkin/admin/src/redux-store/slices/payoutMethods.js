import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

// Helper to get auth headers
const getAuthHeaders = (omitContentType = false) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    const headers = {
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    }

    if (!omitContentType) {
      headers['Content-Type'] = 'application/json'
    }

    return headers
  }

  return {}
}

// Thunk for fetching all payout methods
export const fetchPayoutMethods = createAsyncThunk('payoutMethods/fetchAll', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/payoutMethod/retrievePayoutMethods`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Thunk for creating a new payout method
export const createPayoutMethod = createAsyncThunk('payoutMethods/create', async (formData, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/payoutMethod/createPayoutMethod`, formData, {
      headers: {
        ...getAuthHeaders(true)
      }
    })

    toast.success(response.data.message || 'Payout method created successfully')

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return rejectWithValue(errorMsg)
  }
})

// Thunk for updating a payout method
export const updatePayoutMethod = createAsyncThunk('payoutMethods/update', async (formData, { rejectWithValue }) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/payoutMethod/editPayoutMethod`, formData, {
      headers: {
        ...getAuthHeaders(true)
      }
    })

    toast.success(response.data.message || 'Payout method updated successfully')

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return rejectWithValue(errorMsg)
  }
})

// Thunk for toggling a payout method status
export const togglePayoutMethodStatus = createAsyncThunk(
  'payoutMethods/toggleStatus',
  async (payoutMethodId, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/payoutMethod/updatePayoutMethodStatus?payoutMethodId=${payoutMethodId}`,
        {},
        { headers: getAuthHeaders() }
      )

      toast.success(response.data.message || 'Payout method status updated')

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Thunk for deleting a payout method
export const deletePayoutMethod = createAsyncThunk('payoutMethods/delete', async (payoutMethodId, thunkAPI) => {
  try {
    const response = await axios.delete(
      `${BASE_URL}/api/admin/payoutMethod/removePayoutMethod?payoutMethodId=${payoutMethodId}`,
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Payout method deleted successfully')

    return { id: payoutMethodId, data: response.data }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  payoutMethods: [],
  loading: false,
  initialLoading: true,
  error: null
}

const payoutMethodsSlice = createSlice({
  name: 'payoutMethods',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch payout methods
      .addCase(fetchPayoutMethods.pending, state => {
        state.loading = true
        state.initialLoading = true
        state.error = null
      })
      .addCase(fetchPayoutMethods.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoading = false

        if (action.payload.status) {
          state.payoutMethods = action.payload.data || []
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchPayoutMethods.rejected, (state, action) => {
        state.loading = false
        state.initialLoading = false
        state.error = action.payload
      })

      // Create payout method
      .addCase(createPayoutMethod.pending, state => {
        state.loading = true
      })
      .addCase(createPayoutMethod.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.payoutMethods.push(action.payload.data)
        }
      })
      .addCase(createPayoutMethod.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Update payout method
      .addCase(updatePayoutMethod.pending, state => {
        state.loading = true
      })
      .addCase(updatePayoutMethod.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const updatedMethod = action.payload.data

          state.payoutMethods = state.payoutMethods.map(method =>
            method._id === updatedMethod._id ? updatedMethod : method
          )
        }
      })
      .addCase(updatePayoutMethod.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Toggle payout method status
      .addCase(togglePayoutMethodStatus.pending, state => {
        state.loading = true
      })
      .addCase(togglePayoutMethodStatus.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const updatedMethod = action.payload.data

          state.payoutMethods = state.payoutMethods.map(method =>
            method._id === updatedMethod._id ? { ...method, isActive: updatedMethod.isActive } : method
          )
        }
      })
      .addCase(togglePayoutMethodStatus.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Delete payout method
      .addCase(deletePayoutMethod.pending, state => {
        state.loading = true
      })
      .addCase(deletePayoutMethod.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.data && action.payload.data.status) {
          state.payoutMethods = state.payoutMethods.filter(method => method._id !== action.payload.id)
        }
      })
      .addCase(deletePayoutMethod.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
  }
})

export default payoutMethodsSlice.reducer
