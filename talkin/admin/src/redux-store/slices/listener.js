import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

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

// Fetch listeners with pagination, search, and date range
export const fetchListeners = createAsyncThunk(
  'listener/fetchListeners',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const state = getState()

      // Get parameters from params or state
      const page = params.page || state.listener.page || 1
      const limit = params.limit || state.listener.pageSize || 10
      const searchQuery = params.searchQuery || state.listener.searchQuery || ''
      const startDate = params.startDate || state.listener.startDate || 'All'
      const endDate = params.endDate || state.listener.endDate || 'All'
      const isFake = params.isFake !== undefined ? params.isFake : state.listener.isFake

      const response = await axios.get(`${BASE_URL}/api/admin/listener/fetchListeners`, {
        headers: getAuthHeaders(),
        params: {
          start: page,
          limit,
          search: searchQuery,
          startDate,
          endDate,
          isFake
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Fetch listeners with pagination, search, and date range
export const fetchDropdownUser = createAsyncThunk(
  'listener/retrieveUserList',
  async (params = {}, { rejectWithValue, getState }) => {
    try {
      const response = await axios.get(`${BASE_URL}/api/admin/user/retrieveUserList`, {
        headers: getAuthHeaders(),
        params: {
          search: 'All'
        }
      })

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Create a new listener
export const createListener = createAsyncThunk('listener/createListener', async (formData, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/listener/createListener`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    if (response.data.status) {
      toast.success(response.data.message || 'Listener created successfully')

      return response.data.newListener
    } else {
      return rejectWithValue(response.data.message)
    }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    return rejectWithValue(errorMsg)
  }
})

// Update a listener
export const updateListener = createAsyncThunk(
  'listener/updateListener',
  async ({ listenerId, formData }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/listener/updateListenerProfile`, formData, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        },
        params: { listenerId }
      })

      if (response.data.status) {
        toast.success(response.data.message || 'Listener updated successfully')

        return response.data.data
      } else {
        return rejectWithValue(response.data.message)
      }
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      return rejectWithValue(errorMsg)
    }
  }
)

// Delete a listener
export const deleteListener = createAsyncThunk('listener/deleteListener', async (listenerId, { rejectWithValue }) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/listener/deleteListenerProfile`, {
      headers: getAuthHeaders(),
      params: { listenerId }
    })

    if (response.data.status) {
      toast.success(response.data.message || 'Listener deleted successfully')

      return listenerId
    } else {
      return rejectWithValue(response.data.message)
    }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    return rejectWithValue(errorMsg)
  }
})

// Listener Coin History
export const fetchCoinHistoryListener = createAsyncThunk(
  'user/fetchCoinTransactions',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCoinTransactions`, {
        headers: getAuthHeaders(),
        params: { listenerId: userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// Listener Call History
export const fetchCallHistoryListener = createAsyncThunk(
  'user/fetchCallHistoryListener',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCallHistory`, {
        headers: getAuthHeaders(),
        params: { listenerId: userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

const initialState = {
  listeners: [],
  total: 0,
  loading: false,
  initialLoad: true,
  page: 1,
  pageSize: 10,
  searchQuery: '',
  startDate: 'All',
  endDate: 'All',
  isFake: false,
  error: null,
  selectedListener: null,
  dropDownUser: [],
  history: {
    data: [],
    filteredData: [],
    liveStreamHistory: [],
    total: 0,
    totalIncome: 0,
    totalOutgoing: 0,
    typeWiseStats: [],
    loading: false,
    initialLoading: true,
    page: 1,
    limit: 10,
    hasMore: true,
    error: null
  }
}

const listenerSlice = createSlice({
  name: 'listener',
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
    setIsFake: (state, action) => {
      state.isFake = action.payload
    },
    setSelectedListener: (state, action) => {
      state.selectedListener = action.payload
    },
    resetListenerFilters: state => {
      state.page = 1
      state.searchQuery = ''
      state.startDate = 'All'
      state.endDate = 'All'
    },
    resetHistoryState: state => {
      state.history = {
        data: [],
        filteredData: [],
        liveStreamHistory: [],
        total: 0,
        totalIncome: 0,
        totalOutgoing: 0,
        typeWiseStats: [],
        loading: false,
        initialLoading: true,
        page: 1,
        limit: 10,
        hasMore: true,
        error: null
      }
    }
  },
  extraReducers: builder => {
    builder

      // Handle fetchListeners states
      .addCase(fetchListeners.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchListeners.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.listeners = action.payload.data || []
        state.total = action.payload.total || 0
        state.error = null
      })
      .addCase(fetchListeners.rejected, (state, action) => {
        state.loading = false
        state.initialLoad = false
        state.error = action.payload || 'Failed to fetch listeners'
        toast.error(action.payload || 'Failed to fetch listeners')
      })
      .addCase(fetchDropdownUser.pending, state => {})
      .addCase(fetchDropdownUser.fulfilled, (state, action) => {
        state.dropDownUser = action.payload.data || []
      })
      .addCase(fetchDropdownUser.rejected, (state, action) => {})

      // Handle createListener states
      .addCase(createListener.pending, state => {
        // No state changes needed for pending creation
      })
      .addCase(createListener.fulfilled, (state, action) => {
        // Optionally add the new listener to the state if needed immediately
        state.listeners = [action.payload, ...state.listeners]
        state.total += 1
      })
      .addCase(createListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to create listener'
        toast.error(action.payload || 'Failed to create listener')
      })

      // Handle updateListener states
      .addCase(updateListener.pending, state => {
        // No state changes needed for pending update
      })
      .addCase(updateListener.fulfilled, (state, action) => {
        // Update the listener in the state if it exists
        // const updatedListener = action.payload
        // state.listeners = state.listeners.map(listener =>
        //   listener._id === updatedListener._id ? updatedListener : listener
        // )
      })
      .addCase(updateListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to update listener'
        toast.error(action.payload || 'Failed to update listener')
      })

      // Handle deleteListener states
      .addCase(deleteListener.pending, state => {
        // No state changes needed for pending deletion
      })
      .addCase(deleteListener.fulfilled, (state, action) => {
        // Remove the deleted listener from the state
        state.listeners = state.listeners.filter(listener => listener._id !== action.payload)
        state.total -= 1
      })
      .addCase(deleteListener.rejected, (state, action) => {
        state.error = action.payload || 'Failed to delete listener'
        toast.error(action.payload || 'Failed to delete listener')
      })

    builder
      .addCase(fetchCoinHistoryListener.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCoinHistoryListener.fulfilled, (state, action) => {
        const { data, total } = action.payload

        console.log(data, total)

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        state.history.page = 1
      })
      .addCase(fetchCoinHistoryListener.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      .addCase(fetchCallHistoryListener.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCallHistoryListener.fulfilled, (state, action) => {
        const { data, total } = action.payload
        
        console.log(data, total)

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        state.history.page = 1
      })
      .addCase(fetchCallHistoryListener.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })
  }
})

export const {
  setPage,
  setPageSize,
  setSearchQuery,
  setDateRange,
  setIsFake,
  setSelectedListener,
  resetListenerFilters,
  resetHistoryState
} = listenerSlice.actions

export default listenerSlice.reducer
