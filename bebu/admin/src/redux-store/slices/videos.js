import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

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

// Helper to normalize video data
const normalizeVideoData = video => {
  if (!video) return null

  // If userId is an object, extract just the id
  if (video.userId && typeof video.userId === 'object') {
    const { userId: userObj, ...rest } = video

    return {
      ...rest,
      userId: userObj._id,
      name: userObj.name || video.name,
      userName: userObj.userName || video.userName,
      userImage: userObj.image || video.userImage
    }
  }

  return video
}

// Fetch videos with pagination, filtering, and date range
export const fetchVideos = createAsyncThunk(
  'videos/fetchVideos',
  async ({ type = 'realVideo', start, limit = 10, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // Normalize the start to ensure we're using a valid page number
      const startPage = start ? Number(start) : 1

      const response = await axios.get(
        `${baseURL}/api/admin/video/fetchVideos?type=${type}&start=${startPage}&limit=${limit}&startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      // Store the actual parameters used in the request so Redux state can be updated properly
      return {
        ...response.data,
        type,
        startPage,
        limit,
        startDate,
        endDate
      }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Fetch user list for video creation
export const fetchUserList = createAsyncThunk(
  'videos/fetchUserList',
  async ({ type = 'fake', search = 'All' }, thunkAPI) => {
    try {
      const response = await axios.get(`${baseURL}/api/admin/user/fetchUserList?type=${type}&search=${search}`, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Create video
export const createVideo = createAsyncThunk('videos/createVideo', async ({ userId, formData }, thunkAPI) => {
  try {
    const response = await axios.post(`${baseURL}/api/admin/video/uploadVideo?userId=${userId}`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

// Update video
export const updateVideo = createAsyncThunk('videos/updateVideo', async ({ userId, videoId, formData }, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/video/updateVideoData?userId=${userId}&videoId=${videoId}`,
      formData,
      {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        }
      }
    )

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

// Delete video
export const deleteVideo = createAsyncThunk('videos/deleteVideo', async ({ userId, _id }, thunkAPI) => {
  try {
    const response = await axios.delete(
      `${baseURL}/api/admin/video/removeVideoFromLibrary?userId=${userId}&videoId=${_id}`,
      {
        headers: getAuthHeaders()
      }
    )

    return { ...response.data, _id }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  loading: false,
  initialLoading: true,
  videos: [],
  users: [],
  selectedVideoType: 'realVideo',
  error: null,
  start: 1,
  limit: 10,
  total: 0,
  hasMore: true,
  startDate: 'All',
  endDate: 'All'
}

const videosSlice = createSlice({
  name: 'videos',
  initialState,
  reducers: {
    setVideoType: (state, action) => {
      // Only reset if changing video type
      if (state.selectedVideoType !== action.payload) {
        state.selectedVideoType = action.payload
        state.start = 1
        state.videos = []
        state.hasMore = true
        state.initialLoading = true
        state.startDate = 'All'
        state.endDate = 'All'
      }
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
      state.start = 1
      state.hasMore = true
    },
    resetPagination: state => {
      state.start = 1
      state.videos = []
      state.hasMore = true
      state.initialLoading = true
    },
    setPage: (state, action) => {
      state.start = action.payload
    },
    setLimit: (state, action) => {
      state.limit = action.payload
    }
  },
  extraReducers: builder => {
    // Fetch Videos
    builder.addCase(fetchVideos.pending, (state, action) => {
      state.loading = true

      // Don't modify initialLoading here
    })
    builder.addCase(fetchVideos.fulfilled, (state, action) => {
      state.loading = false
      state.initialLoading = false

      if (action.payload.status) {
        // Update state with the parameters that were used in the API call
        state.start = action.payload.startPage
        state.limit = action.payload.limit
        state.startDate = action.payload.startDate
        state.endDate = action.payload.endDate

        if (action.payload.type === state.selectedVideoType) {
          // Get new videos
          const newVideos = action.payload.videos || []

          // Replace videos array completely (no appending for pagination)
          state.videos = newVideos

          // Update total count
          state.total = action.payload.totalVideo || 0

          // Update hasMore flag
          state.hasMore = state.videos.length < state.total
        }
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })

    builder.addCase(fetchVideos.rejected, (state, action) => {
      state.loading = false
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Fetch Users
    builder.addCase(fetchUserList.pending, state => {
      state.loading = true
    })
    builder.addCase(fetchUserList.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.users = action.payload.data
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchUserList.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create Video
    builder.addCase(createVideo.pending, state => {
      state.loading = true
    })
    builder.addCase(createVideo.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Only add new video if we're currently viewing fake videos
        if (state.selectedVideoType === 'fakeVideo') {
          // Add new video to the beginning of the list
          state.videos = [action.payload.video, ...state.videos]
          state.total += 1
        }

        toast.success(action.payload.message || 'Video created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createVideo.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update Video
    builder.addCase(updateVideo.pending, state => {
      state.loading = true
    })
    builder.addCase(updateVideo.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Normalize the video data before updating state
        const normalizedVideo = normalizeVideoData(action.payload.data)

        // Update the video in the list
        const index = state.videos.findIndex(video => video._id === normalizedVideo._id)

        if (index !== -1) {
          state.videos[index] = normalizedVideo

          // Create a new array to ensure React detects the change
          state.videos = [...state.videos]
        }

        toast.success(action.payload.message || 'Video updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateVideo.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete Video
    builder.addCase(deleteVideo.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteVideo.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.videos = state.videos.filter(video => video._id !== action.payload._id)
        state.total -= 1
        toast.success(action.payload.message || 'Video deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteVideo.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setVideoType, setDateRange, resetPagination, setPage, setLimit } = videosSlice.actions

export default videosSlice.reducer
