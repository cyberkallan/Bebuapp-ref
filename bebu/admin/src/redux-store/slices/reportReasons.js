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

export const fetchReportReasons = createAsyncThunk('reportReasons/fetchReportReasons', async () => {
  const response = await axios.get(`${BASE_URL}/api/admin/reportReason/fetchReportReason`, {
    headers: getAuthHeaders()
  })

  return response.data
})

export const createReportReason = createAsyncThunk('reportReasons/createReportReason', async reason => {
  const response = await axios.post(
    `${BASE_URL}/api/admin/reportReason/addReportReason`,
    { title: reason },
    { headers: getAuthHeaders() }
  )

  return response.data
})
export const updateReportReason = createAsyncThunk('reportReasons/updateReportReason', async reason => {
  const response = await axios.patch(`${BASE_URL}/api/admin/reportReason/modifyReportReason`, reason, {
    headers: getAuthHeaders()
  })

  return response.data
})

export const deleteReportReason = createAsyncThunk('reportReasons/deleteReportReason', async reportReasonId => {
  const response = await axios.delete(
    `${BASE_URL}/api/admin/reportReason/removeReportReason?reportReasonId=${reportReasonId}`,
    {
      headers: getAuthHeaders()
    }
  )

  return response.data
})

const initialState = {
  reportReasons: [],
  initialLoading: false,
  loading: false,
  error: null
}

const reportReasonsSlice = createSlice({
  name: 'reportReasons',
  initialState,
  reducers: {
    clearReportReasonStatus: state => {
      state.error = null
      state.loading = false
    }
  },
  extraReducers: builder => {
    builder.addCase(fetchReportReasons.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchReportReasons.fulfilled, (state, action) => {
      state.initialLoading = false
      state.reportReasons = action.payload.data
    })
    builder.addCase(fetchReportReasons.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload || 'Failed to fetch report reasons')
    })

    // Create report reason
    builder.addCase(createReportReason.pending, state => {
      state.loading = true
    })
    builder.addCase(createReportReason.fulfilled, (state, action) => {
      state.loading = false
      state.reportReasons.push(action.payload.data)
      toast.success('Report reason created successfully')
    })
    builder.addCase(createReportReason.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload || 'Failed to create report reason')
    })

    // Update report reason
    builder.addCase(updateReportReason.pending, state => {
      state.loading = true
    })
    builder.addCase(updateReportReason.fulfilled, (state, action) => {
      state.loading = false
      state.reportReasons = state.reportReasons.map(reason =>
        reason._id === action.payload.data._id ? action.payload.data : reason
      )
      toast.success('Report reason updated successfully')
    })
    builder.addCase(updateReportReason.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload || 'Failed to update report reason')
    })

    // Delete report reason
    builder.addCase(deleteReportReason.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteReportReason.fulfilled, (state, action) => {
      state.loading = false
      state.reportReasons = state.reportReasons.filter(reason => reason._id !== action.payload.data._id)
      toast.success('Report reason deleted successfully')
    })
    builder.addCase(deleteReportReason.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload || 'Failed to delete report reason')
    })
  }
})

export const { clearReportReasonStatus } = reportReasonsSlice.actions
export default reportReasonsSlice.reducer
