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

// Fetch all agency commissions
export const fetchAgencyCommissions = createAsyncThunk('agencyCommission/fetchAll', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/agencyCommission/fetchAllAgencyCommissions`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return rejectWithValue(errorMsg)
  }
})

// Create agency commission
export const createAgencyCommission = createAsyncThunk(
  'agencyCommission/create',
  async (commissionData, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `${BASE_URL}/api/admin/agencyCommission/createAgencyCommission`,
        commissionData,
        {
          headers: getAuthHeaders()
        }
      )

      toast.success(response.data.message || 'Commission created successfully')

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return rejectWithValue(errorMsg)
    }
  }
)

// Update agency commission
export const updateAgencyCommission = createAsyncThunk(
  'agencyCommission/update',
  async (commissionData, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/agencyCommission/updateAgencyCommission`,
        commissionData,
        {
          headers: getAuthHeaders()
        }
      )

      toast.success(response.data.message || 'Commission updated successfully')

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return rejectWithValue(errorMsg)
    }
  }
)

// Delete agency commission
export const deleteAgencyCommission = createAsyncThunk(
  'agencyCommission/delete',
  async (agencyCommissionId, { rejectWithValue }) => {
    try {
      const response = await axios.delete(
        `${BASE_URL}/api/admin/agencyCommission/deleteAgencyCommission?agencyCommissionId=${agencyCommissionId}`,
        {
          headers: getAuthHeaders()
        }
      )

      toast.success(response.data.message || 'Commission deleted successfully')

      return { id: agencyCommissionId, ...response.data }
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return rejectWithValue(errorMsg)
    }
  }
)

const initialState = {
  commissions: [],
  loading: false,
  error: null
}

const agencyCommissionSlice = createSlice({
  name: 'agencyCommission',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch commissions
      .addCase(fetchAgencyCommissions.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchAgencyCommissions.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.commissions = action.payload.data || []
        } else {
          toast.error(action.payload.message)
          state.error = action.payload.message
        }
      })
      .addCase(fetchAgencyCommissions.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Create commission
      .addCase(createAgencyCommission.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(createAgencyCommission.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.commissions.push(action.payload.data)
        } else {
          state.error = action.payload.message
        }
      })
      .addCase(createAgencyCommission.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Update commission
      .addCase(updateAgencyCommission.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(updateAgencyCommission.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const updatedCommission = action.payload.data

          state.commissions = state.commissions.map(commission =>
            commission._id === updatedCommission._id ? updatedCommission : commission
          )
        } else {
          state.error = action.payload.message
        }
      })
      .addCase(updateAgencyCommission.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Delete commission
      .addCase(deleteAgencyCommission.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(deleteAgencyCommission.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.commissions = state.commissions.filter(commission => commission._id !== action.payload.id)
        } else {
          state.error = action.payload.message
        }
      })
      .addCase(deleteAgencyCommission.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
  }
})

export default agencyCommissionSlice.reducer
