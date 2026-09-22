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

// Fetch posts with pagination, filtering, and date range
export const fetchPosts = createAsyncThunk(
  'posts/fetchPosts',
  async ({ type = 'realPost', start, limit = 10, startDate = 'All', endDate = 'All' }, thunkAPI) => {
    try {
      // Access the current state
      const state = thunkAPI.getState().posts

      // Use the state's start value if not provided
      // If it's the first request (start === 1), keep it at 1
      let startPage = start

      // If start wasn't passed or it's not a valid number, use state.start
      if (startPage === undefined || startPage === null) {
        startPage = state.start
      }

      const response = await axios.get(
        `${baseURL}/api/admin/post/fetchUserPosts?type=${type}&start=${startPage}&limit=${limit}&startDate=${startDate}&endDate=${endDate}`,
        {
          headers: getAuthHeaders()
        }
      )

      return { ...response.data, type, startPage }
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
    }
  }
)

// Fetch user list for post creation
export const fetchUserList = createAsyncThunk(
  'posts/fetchUserList',
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

// Create fake post
export const createFakePost = createAsyncThunk('posts/createFakePost', async ({ userId, formData }, thunkAPI) => {
  try {
    const response = await axios.post(`${baseURL}/api/admin/post/uploadAdminFakePost?userId=${userId}`, formData, {
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

// Update post
export const updatePost = createAsyncThunk('posts/updatePost', async ({ userId, postId, formData }, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${baseURL}/api/admin/post/modifyPost?userId=${userId}&postId=${postId}`,
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

// Delete post
export const deletePost = createAsyncThunk('posts/deletePost', async (postId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/admin/post/discardPost?postId=${postId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, postId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  loading: false,
  initialLoading: true,
  posts: [],
  users: [],
  selectedPostType: 'realPost',
  error: null,
  start: 1,
  limit: 10,
  total: 0,
  hasMore: true,
  startDate: 'All',
  endDate: 'All'
}

const postsSlice = createSlice({
  name: 'posts',
  initialState,
  reducers: {
    setPostType: (state, action) => {
      // Only reset if changing post type
      if (state.selectedPostType !== action.payload) {
        state.selectedPostType = action.payload
        state.start = 1
        state.posts = []
        state.hasMore = true
        state.initialLoading = true
        state.startDate = 'All'
        state.endDate = 'All'
      }
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
    },
    resetPagination: state => {
      state.start = 1
    },
    setPage: (state, action) => {
      state.start = action.payload
    }
  },
  extraReducers: builder => {
    builder.addCase(fetchPosts.pending, (state, action) => {
      // Only set initialLoading to true if it's the first fetch
      if (state.start === 1) {
        state.initialLoading = true
      }

      state.loading = true
    })
    builder.addCase(fetchPosts.fulfilled, (state, action) => {
      state.loading = false
      state.initialLoading = false

      if (action.payload.status) {
        // Verify the returned posts are for the currently selected post type
        if (action.payload.type === state.selectedPostType) {
          // Get new posts and ensure they don't have duplicate IDs
          const newPosts = action.payload.data.map(post => ({
            ...post,

            // Normalize data structure
            name: post.userId?.name || post.name,
            userName: post.userId?.userName || post.userName,
            userImage: post.userId?.image || post.userImage,

            // Ensure userId is just the ID
            userId: post.userId?._id || post.userId
          }))

          // Filter out any duplicate posts by ID that might already exist in state
          const existingIds = new Set(state.posts.map(post => post._id))
          const uniqueNewPosts = newPosts.filter(post => !existingIds.has(post._id))

          // If this is the first page (start=1), replace the posts array
          // Otherwise append for infinite scrolling
          if (state.start === 1) {
            state.posts = newPosts
          } else {
            state.posts = [...state.posts, ...uniqueNewPosts]
          }

          state.total = action.payload.total

          // Fix hasMore calculation to be more precise
          state.hasMore = state.posts.length < action.payload.total

          // Only increment start if we received the expected number of posts
          if (uniqueNewPosts.length > 0 && uniqueNewPosts.length >= state.limit) {
            state.start = state.start + 1
          } else if (state.posts.length >= action.payload.total) {
            // We've reached the end
            state.hasMore = false
          }
        }
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })

    builder.addCase(fetchPosts.rejected, (state, action) => {
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

    // Create Fake Post
    builder.addCase(createFakePost.pending, state => {
      state.loading = true
    })
    builder.addCase(createFakePost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Only add new post if we're currently viewing fake posts
        if (state.selectedPostType === 'fakePost') {
          // Normalize the response data to match the structure of posts in the list
          const normalizedData = {
            ...action.payload.data,

            // Extract data from userId object if it exists
            name: action.payload.data.userId?.name || action.payload.data.name,
            userName: action.payload.data.userId?.userName || action.payload.data.userName,
            userImage: action.payload.data.userId?.image || action.payload.data.userImage
          }

          // Add new post to the beginning of the list
          state.posts = [normalizedData, ...state.posts]
          state.total += 1
        }

        toast.success(action.payload.message || 'Post created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createFakePost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update Post
    builder.addCase(updatePost.pending, state => {
      state.loading = true
    })
    builder.addCase(updatePost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        // Update the post in the list
        const index = state.posts.findIndex(post => post._id === action.payload.data._id)

        if (index !== -1) {
          // Normalize the response data to match the structure of posts in the list
          const normalizedData = {
            ...action.payload.data,

            // Extract data from userId object if it exists
            name: action.payload.data.userId?.name || action.payload.data.name,
            userName: action.payload.data.userId?.userName || action.payload.data.userName,
            userImage: action.payload.data.userId?.image || action.payload.data.userImage
          }

          // Update the post with normalized data
          state.posts[index] = normalizedData

          // Create a new array to ensure React detects the change
          state.posts = [...state.posts]
        }

        toast.success(action.payload.message || 'Post updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updatePost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete Post
    builder.addCase(deletePost.pending, state => {
      state.loading = true
    })
    builder.addCase(deletePost.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.posts = state.posts.filter(post => post._id !== action.payload.postId)
        state.total -= 1
        toast.success(action.payload.message || 'Post deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deletePost.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPostType, setDateRange, resetPagination, setPage } = postsSlice.actions

export default postsSlice.reducer
