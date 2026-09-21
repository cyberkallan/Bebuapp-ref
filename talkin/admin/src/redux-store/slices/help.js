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

// Fetch help requests
export const fetchHelpRequests = createAsyncThunk(
  'help/fetchRequests',
  async ({ status = 1, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/help/loadHelpContent?status=${status}&start=${start}&limit=${limit}&startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Solve help request
export const solveHelpRequest = createAsyncThunk('help/solveRequest', async (helpId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/help/resolveUserHelp?helpId=${helpId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    toast.success(response.data.message || 'Help request resolved successfully')

    return { helpId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Delete help request
export const deleteHelpRequest = createAsyncThunk('help/deleteRequest', async (helpId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/help/deleteUserHelp?helpId=${helpId}`, {
      headers: getAuthHeaders()
    })

    toast.success(response.data.message || 'Help request deleted successfully')

    return { helpId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  pendingRequests: [],
  solvedRequests: [],
  loading: false,
  error: null,
  pendingTotal: 0,
  solvedTotal: 0
}

const helpSlice = createSlice({
  name: 'help',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch help requests
      .addCase(fetchHelpRequests.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchHelpRequests.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const { data, total } = action.payload

          // Store requests and total based on their status
          if (action.meta.arg.status === 1) {
            state.pendingRequests = data
            state.pendingTotal = total
          } else {
            state.solvedRequests = data
            state.solvedTotal = total
          }
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchHelpRequests.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Solve help request
      .addCase(solveHelpRequest.fulfilled, (state, action) => {
        const { helpId } = action.payload

        // Remove from pending requests as it's now solved
        state.pendingRequests = state.pendingRequests.filter(request => request._id !== helpId)
      })

      // Delete help request
      .addCase(deleteHelpRequest.fulfilled, (state, action) => {
        const { helpId } = action.payload

        state.pendingRequests = state.pendingRequests.filter(request => request._id !== helpId)
        state.solvedRequests = state.solvedRequests.filter(request => request._id !== helpId)
      })
  }
})

export default helpSlice.reducer
