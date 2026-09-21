import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { baseURL, secretKey } from '@/config'

// Helpers
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

// --------------------------------------------------
// ✅ EXISTING USER LIST THUNKS
// --------------------------------------------------

export const fetchUsers = createAsyncThunk('admin/fetchAllUsers', async (params = {}, thunkAPI) => {
  try {
    const { getState } = thunkAPI
    const { userReducer } = getState()
    const { type, startDate, endDate, page, pageSize } = userReducer

    const result = await axios.get(`${baseURL}/api/admin/user/listRegisteredUsers`, {
      headers: getAuthHeaders(),
      params: {
        start: params.page,
        limit: params.pageSize,
        search: params.searchQuery,
        isOnline: params.isOnline,
        isBlock: params.isBlock,
        isListener: params.isListener,
        startDate: params.startDate || 'All',
        endDate: params.endDate || 'All'
      }
    })
    
    if (result?.error) return thunkAPI.rejectWithValue(result.error)

    return result.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.message)
  }
})

export const toggleUserBlockStatus = createAsyncThunk('users/toggleUserBlock', async (userId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/user/toggleUserBlock`,
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

export const fetchUserDetails = createAsyncThunk('user/listRegisteredUsers', async (userId, thunkAPI) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/user/listRegisteredUsers`, {
      headers: getAuthHeaders(),
      params: { userId }
    })

    return response.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

// User History
export const fetchWalletHistory = createAsyncThunk(
  'user/fetchWalletHistory',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/getWalletHistory`, {
        headers: getAuthHeaders(),
        params: { userId, start: start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// User History
export const fetchCallHistory = createAsyncThunk(
  'user/fetchCallHistory',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/listCallRecords`, {
        headers: getAuthHeaders(),
        params: { userId, start: start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// User History
export const fetchPurchaseHistory = createAsyncThunk(
  'user/fetchPurchaseHistory',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/retrievePurchaseLog`, {
        headers: getAuthHeaders(),
        params: { userId, start: start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// Listener Coin History
export const fetchCoinHistoryListener = createAsyncThunk(
  'user/fetchCoinTransactions',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCoinTransactions`, {
        headers: getAuthHeaders(),
        params: { listenerId: userId, start: effectiveStart, limit, startDate, endDate }
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
        params: { listenerId: userId, start: effectiveStart, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// --------------------------------------------------
// ✅ NEW MODAL TAB THUNKS
// --------------------------------------------------

export const fetchUserFollowers = createAsyncThunk(
  'user/fetchUserFollowers',
  async ({ userId, start = 1, limit = 20 }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/followerFollowing/fetchUserFollowers`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchUserFollowing = createAsyncThunk(
  'user/fetchUserFollowing',
  async ({ userId, start = 1, limit = 20 }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/followerFollowing/fetchUserFollowing`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchUserFriends = createAsyncThunk(
  'user/fetchUserFriends',
  async ({ userId, start = 1, limit = 20 }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/followerFollowing/fetchUserFriends`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchBlockedUserList = createAsyncThunk(
  'user/fetchBlockedUserList',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/block/fetchBlockedUserList`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchUserPosts = createAsyncThunk(
  'user/fetchUserPosts',
  async ({ userId, start = 1, limit = 8, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/post/listUserPosts`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      console.error('Error fetching user posts:', err)

      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchUserVideos = createAsyncThunk('user/fetchUserVideos', async ({ userId }, thunkAPI) => {
  try {
    const res = await axios.get(`${baseURL}/api/admin/video/getUserMediaLibrary`, {
      headers: getAuthHeaders(),
      params: { userId }
    })

    return res.data
  } catch (err) {
    console.error('Error fetching user videos:', err)

    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

export const registerFakeUser = createAsyncThunk('users/registerFakeUser', async (userData, thunkAPI) => {
  try {
    const response = await axios.post(`${baseURL}/api/admin/user/registerFakeUser`, userData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to register fake user')
    }

    toast.success(response.data.message || 'Fake user registered successfully')

    return response.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

export const modifyUserProfile = createAsyncThunk('users/modifyUserProfile', async (userData, thunkAPI) => {
  try {
    const response = await axios.patch(`${baseURL}/api/admin/user/modifyUserProfile`, userData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to update user')
    }

    toast.success(response.data.message || 'User updated successfully')

    return response.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

export const deleteUser = createAsyncThunk('users/deleteUser', async (userId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/admin/user/deleteUser`, {
      headers: getAuthHeaders(),
      params: { userId }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to delete user')
    }

    toast.success(response.data.message || 'User deleted successfully')

    return { userId, ...response.data }
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// --------------------------------------------------
// ✅ HISTORY TAB THUNKS
// --------------------------------------------------

export const fetchCoinHistory = createAsyncThunk(
  'user/fetchCoinHistory',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchCoinHistory`, {
        headers: getAuthHeaders(),
        params: { userId, start: effectiveStart, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// New API thunks for the user history tabs

export const fetchFilteredCoinHistory = createAsyncThunk(
  'user/fetchFilteredCoinHistory',
  async ({ userId, start = 1, limit = 20, startDate = 'All', endDate = 'All', type }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/history/fetchTypeFilteredCoinHistory`, {
        headers: getAuthHeaders(),
        params: { userId, start: effectiveStart, limit, startDate, endDate, type }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchLiveStreamHistory = createAsyncThunk(
  'user/fetchLiveStreamHistory',
  async ({ userId, start = 1, limit = 10, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // If we have date filters, always start from page 1 to avoid pagination issues
      const effectiveStart = startDate !== 'All' || endDate !== 'All' ? 1 : start

      const res = await axios.get(`${baseURL}/api/admin/liveStreamerHistory/getLiveSessionHistory`, {
        headers: getAuthHeaders(),
        params: { userId, start: effectiveStart, limit, startDate, endDate }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// --------------------------------------------------
// ✅ LIVE USER MANAGEMENT THUNKS
// --------------------------------------------------

// Create a new live streaming user
export const createLiveUser = createAsyncThunk('liveUsers/createLiveUser', async (userData, thunkAPI) => {
  try {
    const response = await axios.post(`${baseURL}/api/admin/fakeLiveStreamer/registerFakeUserWithStream`, userData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to create live user')
    }

    toast.success(response.data.message || 'Live user created successfully')

    return response.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Update an existing live streaming user
export const updateLiveUser = createAsyncThunk('liveUsers/updateLiveUser', async (userData, thunkAPI) => {
  try {
    const response = await axios.patch(`${baseURL}/api/admin/fakeLiveStreamer/updateFakeUserStream`, userData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to update live user')
    }

    toast.success(response.data.message || 'Live user updated successfully')

    return response.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Delete a live streaming user
export const deleteLiveUser = createAsyncThunk('liveUsers/deleteLiveUser', async (streamerId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/admin/fakeLiveStreamer/deleteFakeLiveStreamer`, {
      headers: getAuthHeaders(),
      params: { streamerId }
    })

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to delete live user')
    }

    toast.success(response.data.message || 'Live user deleted successfully')

    return { streamerId, ...response.data }
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Toggle streaming status for a live user
export const toggleStreamingStatus = createAsyncThunk(
  'liveUsers/toggleStreamingStatus',
  async (streamerId, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${baseURL}/api/admin/fakeLiveStreamer/toggleStreamerStreamingStatus`,
        {},
        {
          headers: getAuthHeaders(),
          params: { streamerId }
        }
      )

      if (!response.data.status) {
        throw new Error(response.data.message || 'Failed to toggle streaming status')
      }

      toast.success(response.data.message || 'Streaming status updated successfully')

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message

      toast.error(errorMessage)

      return thunkAPI.rejectWithValue(errorMessage)
    }
  }
)

// Profile Visitors Thunks
export const fetchProfileVisitors = createAsyncThunk(
  'user/fetchProfileVisitors',
  async ({ userId, start = 1, limit = 20 }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/profileVisitor/fetchProfileVisitors`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

export const fetchVisitedProfiles = createAsyncThunk(
  'user/fetchVisitedProfiles',
  async ({ userId, start = 1, limit = 20 }, thunkAPI) => {
    try {
      const res = await axios.get(`${baseURL}/api/admin/profileVisitor/fetchVisitedProfiles`, {
        headers: getAuthHeaders(),
        params: { userId, start, limit }
      })

      return res.data
    } catch (err) {
      return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
    }
  }
)

// --------------------------------------------------
// ✅ SLICE SETUP
// --------------------------------------------------

const userSlice = createSlice({
  name: 'users',
  initialState: {
    initialLoad: true,
    startDate: 'All',
    endDate: 'All',
    data: {},
    user: [],
    userCount: [],
    total: 0,
    searchQuery: '',
    type: 1,
    page: 1,
    pageSize: 10,
    status: 'idle',
    error: null,
    userDetails: null,
    initialLoading: true,
    loading: false,
    streamType: null, // For filtering live users by type
    filters: {
      status: 'All',
      role: 'All'
    },

    // Modal Loading State
    modalLoading: {
      followers: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      following: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      friends: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      posts: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      videos: { initialLoading: true, loading: false, error: null },
      visitors: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      visited: { initialLoading: true, loading: false, reachedEnd: false, page: 1 },
      blocked: { initialLoading: true, loading: false, reachedEnd: false, page: 1 }
    },

    modalData: {
      followers: [],
      following: [],
      friends: [],
      posts: [],
      videos: [],
      visitors: [],
      visited: [],
      blocked: []
    },

    // History Tab State
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
  },

  reducers: {
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate

      // // Reset history pagination when date range changes
      // if (state.history) {
      //   state.history.page = 1
      //   state.history.data = []
      //   state.history.filteredData = []
      //   state.history.hasMore = true
      //   state.history.initialLoading = true
      // }
    },
    setSearchQuery: (state, action) => {
      state.searchQuery = action.payload
    },
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
    },
    setHistoryPage: (state, action) => {
      state.history.page = action.payload
    },
    setHistoryPageSize: (state, action) => {
      state.history.limit = action.payload
    },
    setType: (state, action) => {
      state.type = action.payload
    },
    setStreamType: (state, action) => {
      state.streamType = action.payload
    },
    setFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload }
    },
    resetModalTab: (state, action) => {
      const tab = action.payload

      state.modalData[tab] = []
      state.modalLoading[tab] = {
        initialLoading: true,
        loading: false,
        reachedEnd: false,
        page: 1
      }
    },
    resetUserState: state => {
      // Store current type before reset
      const currentType = state.type
      const currentStreamType = state.streamType
      const currentFilters = { ...state.filters }

      // Reset user data to prevent data mixing between different user types
      state.user = []
      state.userCount = []
      state.total = 0
      state.data = {}

      // Clear search params
      state.searchQuery = ''
      state.page = 1

      // Restore the user type - this prevents type from being lost during reset
      state.type = currentType
      state.streamType = currentStreamType
      state.filters = currentFilters
      state.startDate = 'All'
      state.endDate = 'All'

      // Set initialLoad to true to ensure loading state shows
      state.initialLoad = true
      state.status = 'idle'
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
    },
    setHistoryActiveType: (state, action) => {
      state.history.activeType = action.payload
      state.history.page = 1
      state.history.filteredData = []
      state.history.hasMore = true
    },
    setUserData: (state, action) => {
      state.userDetails = action.payload
    }
  },

  extraReducers: builder => {
    // -------------------- MAIN USER TABLE --------------------
    builder
      .addCase(fetchUsers.pending, state => {
        // If we're already in a loading state, don't change initialLoad
        // This prevents flickering when navigating between pages
        state.status = 'loading'

        // Only set initialLoad to true on the very first load
        // If we already have user data, don't reset the initialLoad flag
        if (state.initialLoad === undefined && (!state.user || state.user.length === 0)) {
          state.initialLoad = true
        }

        state.loading = true
      })
      .addCase(fetchUsers.fulfilled, (state, action) => {
        // Always set these regardless of response status
        state.status = action.payload.status ? 'succeeded' : 'failed'
        state.initialLoad = false

        if (action.payload.status) {
          // Handle different response formats for different user types

          // Regular users response format
          state.user = action.payload.data
          state.total = action.payload.total
          state.data = {
            activeUsers: action.payload.totalActiveUsers,
            maleUsers: action.payload.totalMaleUsers,
            femaleUsers: action.payload.totalFemaleUsers
          }
          state.loading = false
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchUsers.rejected, (state, action) => {
        state.status = 'failed'
        state.initialLoad = false
        state.loading = false

        toast.error(action.payload.message)
      })

      .addCase(toggleUserBlockStatus.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          state.user = state.user.map(user =>
            user._id === action.payload.data._id ? { ...user, isBlock: action.payload.data.isBlock } : user
          )
          state.status = 'succeeded'
        }
      })
      .addCase(toggleUserBlockStatus.rejected, (state, action) => {
        state.status = 'failed'
      })

    // -------------------- MODAL HANDLERS --------------------
    const handleModalTabState = (builder, type, apiThunk, key) => {
      builder
        .addCase(apiThunk.pending, state => {
          const tab = state.modalLoading[type]

          tab.loading = true
          if (tab.page === 1) tab.initialLoading = true
        })
        .addCase(apiThunk.fulfilled, (state, action) => {
          const tab = state.modalLoading[type]
          const payload = action.payload || {}

          tab.initialLoading = false
          tab.loading = false

          if (payload.status) {
            const newData = payload[key] || []
            const requestedLimit = action.meta?.arg?.limit || 20
            const totalItems = payload.total || 0

            const currentTotal = state.modalData[type].length + newData.length
            const isEnd = currentTotal >= totalItems || newData.length === 0 || newData.length < requestedLimit

            tab.page += 1
            tab.reachedEnd = isEnd

            const enhancedData = newData.map(item => ({
              ...item,
              _response: {
                total: totalItems
              }
            }))

            state.modalData[type] = [...state.modalData[type], ...enhancedData]
          } else {
            tab.reachedEnd = true
            toast.error(payload.message || 'Something went wrong')
          }
        })
        .addCase(apiThunk.rejected, (state, action) => {
          const tab = state.modalLoading[type]

          tab.initialLoading = false
          tab.loading = false
          tab.reachedEnd = true
          toast.error(action.payload || 'Request failed')
        })
    }

    handleModalTabState(builder, 'followers', fetchUserFollowers, 'followers')
    handleModalTabState(builder, 'following', fetchUserFollowing, 'following')
    handleModalTabState(builder, 'friends', fetchUserFriends, 'friends')
    handleModalTabState(builder, 'posts', fetchUserPosts, 'data')
    handleModalTabState(builder, 'blocked', fetchBlockedUserList, 'blockedUsers')

    builder
      .addCase(fetchUserVideos.pending, state => {
        state.modalLoading.videos.initialLoading = true
        state.modalLoading.videos.loading = true
        state.modalLoading.videos.error = null
      })
      .addCase(fetchUserVideos.fulfilled, (state, action) => {
        state.modalLoading.videos.initialLoading = false
        state.modalLoading.videos.loading = false

        if (action.payload?.status) {
          state.modalData.videos = action.payload.data || []
        } else {
          state.modalLoading.videos.error = action.payload?.message || 'Failed to fetch videos'
        }
      })
      .addCase(fetchUserVideos.rejected, (state, action) => {
        state.modalLoading.videos.initialLoading = false
        state.modalLoading.videos.loading = false
        state.modalLoading.videos.error = action.payload || 'Failed to fetch videos'
      })

    // -------------------- FAKE USER REGISTRATION --------------------
    builder

      // .addCase(registerFakeUser.pending, state => {
      //   state.status = 'loading'
      // })
      .addCase(registerFakeUser.fulfilled, (state, action) => {
        state.status = 'succeeded'

        if (state.type === 2 && action.payload?.status && action.payload?.data) {
          const newUser = action.payload.data

          state.user = [newUser, ...state.user]

          if (state.total) state.total += 1

          if (state.data) {
            if (state.data.activeUsers) state.data.activeUsers += 1

            if (newUser.gender === 'Male' && state.data.maleUsers) {
              state.data.maleUsers += 1
            } else if (newUser.gender === 'Female' && state.data.femaleUsers) {
              state.data.femaleUsers += 1
            }
          }
        }
      })

    // .addCase(registerFakeUser.rejected, (state, action) => {
    //   state.status = 'failed'
    //   state.error = action.payload
    // })

    // -------------------- USER PROFILE MODIFICATION --------------------
    builder

      // .addCase(modifyUserProfile.pending, state => {
      //   state.status = 'loading'
      // })
      .addCase(modifyUserProfile.fulfilled, (state, action) => {
        // state.status = 'succeeded'

        if (action.payload?.status && action.payload?.data) {
          const updatedUser = action.payload.data

          // Update the user in the users array
          state.user = state.user.map(user => (user._id === updatedUser._id ? { ...user, ...updatedUser } : user))
        }
      })
      .addCase(modifyUserProfile.rejected, (state, action) => {
        // state.status = 'failed'
        // state.error = action.payload
      })

      // -------------------- USER DELETION --------------------
      .addCase(deleteUser.fulfilled, (state, action) => {
        if (action.payload?.status) {
          // Remove the deleted user from the state
          state.user = state.user.filter(user => user._id !== action.payload.userId)

          // Update the total count
          if (state.total) state.total -= 1

          // Update user counts in the data object (if applicable)
          const deletedUser = state.user.find(user => user._id === action.payload.userId)

          if (state.data && deletedUser) {
            // Decrement active users count
            if (state.data.activeUsers) state.data.activeUsers -= 1

            // Update gender counts
            if (deletedUser.gender === 'Male' && state.data.maleUsers) {
              state.data.maleUsers -= 1
            } else if (deletedUser.gender === 'Female' && state.data.femaleUsers) {
              state.data.femaleUsers -= 1
            }
          }
        }
      })

    // -------------------- USER VIEW --------------------
    builder
      .addCase(fetchUserDetails.pending, state => {
        state.status = 'loading'
        state.initialLoading = true
      })
      .addCase(fetchUserDetails.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.userDetails = action.payload.data[0]
        state.initialLoading = false
      })
      .addCase(fetchUserDetails.rejected, (state, action) => {
        state.status = 'failed'
        state.initialLoading = false
      })

    // History Tab Reducers
    builder
      .addCase(fetchCoinHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCoinHistory.fulfilled, (state, action) => {
        const { data, total, totalIncome, totalOutgoing, typeWiseStats } = action.payload

        console.log('state.history.data', action.payload)

        state.history.total = total
        state.history.data = data
        state.history.totalIncome = totalIncome
        state.history.totalOutgoing = totalOutgoing
        state.history.typeWiseStats = typeWiseStats || []
        state.history.loading = false
        state.history.initialLoading = false

        // state.history.hasMore = uniqueNewData.length > 0 && state.history.data.length < total
        state.history.page += 1
      })
      .addCase(fetchCoinHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      .addCase(fetchFilteredCoinHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchFilteredCoinHistory.fulfilled, (state, action) => {
        const { data, total, totalIncome, totalOutgoing, typeWiseStats } = action.payload

        // Prevent duplicate entries by tracking IDs
        const existingIds = new Set(state.history.filteredData.map(item => item._id))
        const uniqueNewData = data.filter(item => !existingIds.has(item._id))

        // If it's the first page, replace data; otherwise append unique items
        if (state.history.page === 1) {
          state.history.filteredData = data
        } else {
          state.history.filteredData = [...state.history.filteredData, ...uniqueNewData]
        }

        state.history.total = total
        state.history.totalIncome = totalIncome || state.history.totalIncome
        state.history.totalOutgoing = totalOutgoing || state.history.totalOutgoing
        state.history.typeWiseStats = typeWiseStats || state.history.typeWiseStats
        state.history.loading = false
        state.history.initialLoading = false
        state.history.hasMore = uniqueNewData.length > 0 && state.history.filteredData.length < total
        state.history.page += 1
      })
      .addCase(fetchFilteredCoinHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      // Wallet History
      .addCase(fetchWalletHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchWalletHistory.fulfilled, (state, action) => {
        const { data, total, totalIncome, totalOutgoing, typeWiseStat } = action.payload

        state.history.data = data
        state.history.total = total
        state.history.totalIncome = totalIncome || state.history.totalIncome
        state.history.totalOutgoing = totalOutgoing || state.history.totalOutgoing
        state.history.typeWiseStats = typeWiseStat || state.history.typeWiseStats
        state.history.loading = false
        state.history.initialLoading = false

        // state.history.hasMore = uniqueNewData.length > 0 && state.history.data.length < total
        state.history.page += 1
      })
      .addCase(fetchWalletHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      // Call History
      .addCase(fetchCallHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchCallHistory.fulfilled, (state, action) => {
        const { data, total } = action.payload

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        
        // state.history.hasMore = uniqueNewData.length > 0 && state.history.data.length < total
        state.history.page += 1
      })
      .addCase(fetchCallHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

      // Purchase History
      .addCase(fetchPurchaseHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchPurchaseHistory.fulfilled, (state, action) => {
        const { data, total } = action.payload
        
        console.log(data, total)

        state.history.data = data
        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false

        // state.history.hasMore = uniqueNewData.length > 0 && state.history.data.length < total
        state.history.page = 1
      })
      .addCase(fetchPurchaseHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })

    // Coin History Listener
    // builder
    //   .addCase(fetchCoinHistoryListener.pending, state => {
    //     state.history.loading = true
    //   })
    //   .addCase(fetchCoinHistoryListener.fulfilled, (state, action) => {
    //     const { data, total } = action.payload
    //     console.log(data, total)

    //     state.history.data = data
    //     state.history.total = total
    //     state.history.loading = false
    //     state.history.initialLoading = false
    //     state.history.page = 1
    //   })
    //   .addCase(fetchCoinHistoryListener.rejected, (state, action) => {
    //     state.history.loading = false
    //     state.history.initialLoading = false
    //     state.history.error = action.payload
    //   })

    //   .addCase(fetchCallHistoryListener.pending, state => {
    //     state.history.loading = true
    //   })
    //   .addCase(fetchCallHistoryListener.fulfilled, (state, action) => {
    //     const { data, total } = action.payload
    //     console.log(data, total)

    //     state.history.data = data
    //     state.history.total = total
    //     state.history.loading = false
    //     state.history.initialLoading = false
    //     state.history.page = 1
    //   })
    //   .addCase(fetchCallHistoryListener.rejected, (state, action) => {
    //     state.history.loading = false
    //     state.history.initialLoading = false
    //     state.history.error = action.payload
    //   })

    // -------------------- LIVE USER MANAGEMENT --------------------
    builder
      .addCase(createLiveUser.fulfilled, (state, action) => {
        if (action.payload?.status && action.payload?.data) {
          // Add new live user to the state if we're in live users mode
          if (state.type === 3) {
            // Only append if streamType matches first user's streamType
            if (state.user && state.user.length > 0) {
              if (state.user[0].streamType === action.payload.data.streamType) {
                state.user = [action.payload.data, ...state.user]
                if (state.total) state.total += 1
              }
            } else {
              // If no users exist yet, add the first one
              state.user = [action.payload.data]
              if (state.total) state.total += 1
            }
          }
        }
      })

      .addCase(updateLiveUser.fulfilled, (state, action) => {
        if (action.payload?.status && action.payload?.data) {
          // Update the live user in the state
          const updatedUser = action.payload.data

          state.user = state.user.map(user => (user._id === updatedUser._id ? { ...user, ...updatedUser } : user))
        }
      })

      .addCase(deleteLiveUser.fulfilled, (state, action) => {
        if (action.payload?.status) {
          // Remove the deleted live user from the state
          state.user = state.user.filter(user => user._id !== action.payload.streamerId)
          if (state.total) state.total -= 1
        }
      })

      .addCase(toggleStreamingStatus.fulfilled, (state, action) => {
        if (action.payload?.status && action.payload?.data) {
          // Update the isStreaming status in the state
          const updatedUser = action.payload.data

          state.user = state.user.map(user =>
            user._id === updatedUser._id ? { ...user, isStreaming: updatedUser.isStreaming } : user
          )
        }
      })

    // Profile Visitors Reducers
    builder
      .addCase(fetchProfileVisitors.pending, state => {
        const tab = state.modalLoading.visitors

        tab.loading = true

        if (tab.page === 1) {
          tab.initialLoading = true

          // Reset data when loading first page
          state.modalData.visitors = []
        }
      })
      .addCase(fetchProfileVisitors.fulfilled, (state, action) => {
        const tab = state.modalLoading.visitors
        const payload = action.payload || {}

        tab.initialLoading = false
        tab.loading = false

        if (payload.status) {
          const newData = payload.visitors || []
          const requestedLimit = action.meta?.arg?.limit || 20
          const totalItems = payload.total || 0

          // Create a Set of existing IDs for O(1) lookup
          const existingIds = new Set(state.modalData.visitors.map(item => item._id))

          // Filter out duplicates
          const uniqueNewData = newData.filter(item => !existingIds.has(item._id))

          const currentTotal = state.modalData.visitors.length + uniqueNewData.length
          const isEnd = currentTotal >= totalItems || newData.length === 0 || newData.length < requestedLimit

          tab.page += 1
          tab.reachedEnd = isEnd

          const enhancedData = uniqueNewData.map(item => ({
            ...item,
            _response: {
              total: totalItems
            }
          }))

          state.modalData.visitors = [...state.modalData.visitors, ...enhancedData]
        } else {
          tab.reachedEnd = true
          toast.error(payload.message || 'Something went wrong')
        }
      })

    // Visited Profiles Reducers
    builder
      .addCase(fetchVisitedProfiles.pending, state => {
        const tab = state.modalLoading.visited

        tab.loading = true

        if (tab.page === 1) {
          tab.initialLoading = true

          // Reset data when loading first page
          state.modalData.visited = []
        }
      })
      .addCase(fetchVisitedProfiles.fulfilled, (state, action) => {
        const tab = state.modalLoading.visited
        const payload = action.payload || {}

        tab.initialLoading = false
        tab.loading = false

        if (payload.status) {
          const newData = payload.visitedProfiles || []
          const requestedLimit = action.meta?.arg?.limit || 20
          const totalItems = payload.total || 0

          // Create a Set of existing IDs for O(1) lookup
          const existingIds = new Set(state.modalData.visited.map(item => item._id))

          // Filter out duplicates
          const uniqueNewData = newData.filter(item => !existingIds.has(item._id))

          const currentTotal = state.modalData.visited.length + uniqueNewData.length
          const isEnd = currentTotal >= totalItems || newData.length === 0 || newData.length < requestedLimit

          tab.page += 1
          tab.reachedEnd = isEnd

          const enhancedData = uniqueNewData.map(item => ({
            ...item,
            _response: {
              total: totalItems
            }
          }))

          state.modalData.visited = [...state.modalData.visited, ...enhancedData]
        } else {
          tab.reachedEnd = true
          toast.error(payload.message || 'Something went wrong')
        }
      })

    // -------------------- LIVE STREAM HISTORY --------------------
    builder
      .addCase(fetchLiveStreamHistory.pending, state => {
        state.history.loading = true
      })
      .addCase(fetchLiveStreamHistory.fulfilled, (state, action) => {
        const { data, total } = action.payload

        // Prevent duplicate entries by tracking IDs
        const existingIds = new Set(state.history.liveStreamHistory.map(item => item._id))
        const uniqueNewData = data.filter(item => !existingIds.has(item._id))

        // If it's the first page, replace data; otherwise append unique items
        if (state.history.page === 1) {
          state.history.liveStreamHistory = data
        } else {
          state.history.liveStreamHistory = [...state.history.liveStreamHistory, ...uniqueNewData]
        }

        state.history.total = total
        state.history.loading = false
        state.history.initialLoading = false
        state.history.hasMore = uniqueNewData.length > 0 && state.history.liveStreamHistory.length < total
        state.history.page += 1
      })
      .addCase(fetchLiveStreamHistory.rejected, (state, action) => {
        state.history.loading = false
        state.history.initialLoading = false
        state.history.error = action.payload
      })
  }
})

export const {
  setSearchQuery,
  setPage,
  setPageSize,
  setType,
  setStreamType,
  setFilters,
  resetModalTab,
  resetUserState,
  resetHistoryState,
  setHistoryActiveType,
  setDateRange,
  setUserData,
  setHistoryPageSize,
  setHistoryPage
} = userSlice.actions

export default userSlice.reducer
