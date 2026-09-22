// ✅ Updated Redux Slice: hostApplication.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

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

export const fetchHosts = createAsyncThunk('hostApplication/fetchHosts', async (params, thunkAPI) => {
  try {
    const res = await axios.get(`${baseURL}/api/admin/host/retrieveHosts`, {
      headers: getAuthHeaders(),
      params: {
        startDate: params.startDate,
        endDate: params.endDate,
        type: params.type,
        search: params.searchQuery,
        start: params.page,
        limit: params.pageSize
      }
    })

    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

export const fetchHostsByAgency = createAsyncThunk('hostApplication/fetchHostsByAgency', async (params, thunkAPI) => {
  try {
    const res = await axios.get(`${baseURL}/api/admin/agency/fetchAgencyHostList`, {
      headers: getAuthHeaders(),
      params: {
        agencyId: params.agencyId,
        start: params.page,
        limit: params.pageSize,
        search: params.searchQuery
      }
    })

    return res.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

export const toggleHostBlockStatus = createAsyncThunk('users/toggleUserBlockStatus', async (userId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/user/toggleUserBlockStatus`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          userId: userId.id
        }
      }
    )

    if (!response.data.status) throw new Error(response.data.message)

    return response.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

const initialState = {
  hostList: [],
  hostStats: {},
  hostPage: 1,
  hostPageSize: 10,
  hostType: 'All',
  hostSearch: '',
  hostStartDate: 'All',
  hostEndDate: 'All',
  hostInitialLoad: true,
  hostLoading: false
}

const hostApplicationSlice = createSlice({
  name: 'hostApplication',
  initialState,
  reducers: {
    setHostPage: (state, action) => {
      state.hostPage = action.payload
    },
    setHostPageSize: (state, action) => {
      state.hostPageSize = action.payload
    },
    setHostSearch: (state, action) => {
      state.hostSearch = action.payload
    },
    setHostType: (state, action) => {
      state.hostType = action.payload
      state.hostPage = 1
    },
    setHostDateRange: (state, action) => {
      state.hostStartDate = action.payload.startDate
      state.hostEndDate = action.payload.endDate
    }
  },
  extraReducers: builder => {
    builder
      .addCase(fetchHosts.pending, state => {
        state.hostLoading = true
        state.hostInitialLoad = true
      })
      .addCase(fetchHosts.fulfilled, (state, action) => {
        state.hostLoading = false
        state.hostInitialLoad = false

        if (action.payload?.status) {
          state.hostList = action.payload.data || []
          state.hostStats = {
            total: action.payload.total || 0,
            totalActiveHosts: action.payload.totalActiveHosts || 0,
            totalVIPHosts: action.payload.totalVIPHosts || 0,
            totalMaleHosts: action.payload.totalMaleHosts || 0,
            totalFemaleHosts: action.payload.totalFemaleHosts || 0
          }
        } else {
          state.hostList = []
          state.hostStats = {}
          toast.error(action.payload?.message || 'Failed to fetch hosts')
        }
      })
      .addCase(fetchHosts.rejected, (state, action) => {
        state.hostLoading = false
        state.hostInitialLoad = false
        state.hostList = []
        toast.error(action.payload || 'Failed to fetch hosts')
      })

      // Fetch hosts by agency
      .addCase(fetchHostsByAgency.pending, state => {
        state.hostLoading = true
        state.hostInitialLoad = true
      })
      .addCase(fetchHostsByAgency.fulfilled, (state, action) => {
        state.hostLoading = false
        state.hostInitialLoad = false

        console.log(action.payload)

        if (action.payload?.status) {
          state.hostList = action.payload.hosts || []
          state.hostStats = {
            total: action.payload.total || 0
          }
        } else {
          state.hostList = []
          toast.error(action.payload?.message || 'Failed to fetch hosts')
        }
      })
      .addCase(fetchHostsByAgency.rejected, (state, action) => {
        state.hostLoading = false
        state.hostInitialLoad = false
        state.hostList = []
        toast.error(action.payload || 'Failed to fetch hosts')
      })

      // Toggle user block status
      .addCase(toggleHostBlockStatus.fulfilled, (state, action) => {
        if (action.payload.status) {
          state.hostList = state.hostList.map(host =>
            host._id === action.payload.data._id ? { ...host, isBlock: action.payload.data.isBlock } : host
          )
        }
      })
      .addCase(toggleHostBlockStatus.rejected, (state, action) => {
        toast.error(action.payload || 'Failed to toggle host block status')
      })
  }
})

export const { setHostPage, setHostPageSize, setHostSearch, setHostType, setHostDateRange } =
  hostApplicationSlice.actions

export default hostApplicationSlice.reducer
