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

// Fetch reports
export const fetchReports = createAsyncThunk(
  'reports/fetchReports',
  async ({ type = 1, status = 1, startDate = 'All', endDate = 'All', start = 1, limit = 20 }, thunkAPI) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/report/fetchReports?type=${type}&status=${status}&startDate=${startDate}&endDate=${endDate}&start=${start}&limit=${limit}`,
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

// Solve report
export const solveReport = createAsyncThunk('reports/solveReport', async (reportId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/report/resolveReport?reportId=${reportId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    toast.success(response.data.message || 'Report resolved successfully')

    return { reportId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Delete report
export const deleteReport = createAsyncThunk('reports/deleteReport', async (reportId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/report/removeReport?reportId=${reportId}`, {
      headers: getAuthHeaders()
    })

    toast.success(response.data.message || 'Report deleted successfully')

    return { reportId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  videoReports: {
    pending: [],
    solved: []
  },
  postReports: {
    pending: [],
    solved: []
  },
  userReports: {
    pending: [],
    solved: []
  },
  loading: false,
  initialLoad: true,
  error: null,
  total: 0
}

const reportsSlice = createSlice({
  name: 'reports',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch reports
      .addCase(fetchReports.pending, state => {
        state.error = null
      })
      .addCase(fetchReports.fulfilled, (state, action) => {
        state.initialLoad = false

        if (action.payload.status) {
          const { data, total } = action.payload

          state.total = total

          // Determine which category to update based on type and status
          const { type, status } = action.meta.arg
          let targetCategory

          switch (type) {
            case 1:
              targetCategory = state.videoReports
              break
            case 2:
              targetCategory = state.postReports
              break
            case 3:
              targetCategory = state.userReports
              break
            default:
              return
          }

          if (status === 1) {
            targetCategory.pending = data
          } else {
            targetCategory.solved = data
          }
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchReports.rejected, (state, action) => {
        state.initialLoad = false
        state.error = action.payload
      })

      // Solve report
      .addCase(solveReport.fulfilled, (state, action) => {
        const { reportId } = action.payload

        // Remove from pending lists
        state.videoReports.pending = state.videoReports.pending.filter(report => report._id !== reportId)
        state.postReports.pending = state.postReports.pending.filter(report => report._id !== reportId)
        state.userReports.pending = state.userReports.pending.filter(report => report._id !== reportId)
      })

      // Delete report
      .addCase(deleteReport.fulfilled, (state, action) => {
        const { reportId } = action.payload

        // Remove from all lists
        state.videoReports.pending = state.videoReports.pending.filter(report => report._id !== reportId)
        state.videoReports.solved = state.videoReports.solved.filter(report => report._id !== reportId)
        state.postReports.pending = state.postReports.pending.filter(report => report._id !== reportId)
        state.postReports.solved = state.postReports.solved.filter(report => report._id !== reportId)
        state.userReports.pending = state.userReports.pending.filter(report => report._id !== reportId)
        state.userReports.solved = state.userReports.solved.filter(report => report._id !== reportId)
      })
  }
})

export default reportsSlice.reducer
