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

export const fetchHashtags = createAsyncThunk('hashtags/fetchHashtags', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/hashTag/retrieveHashtags?start=1&limit=20`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const createHashtag = createAsyncThunk('hashtags/createHashtag', async (payload, thunkAPI) => {
  try {
    const response = await axios.post(`${baseURL}/api/admin/hashTag/addNewHashtag`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const updateHashtag = createAsyncThunk('hashtags/updateHashtag', async (payload, thunkAPI) => {
  try {
    const response = await axios.patch(`${baseURL}/api/admin/hashTag/modifyHashtag`, payload, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

export const deleteHashtag = createAsyncThunk('hashtags/deleteHashtag', async (hashTagId, thunkAPI) => {
  try {
    const response = await axios.delete(`${baseURL}/api/admin/hashTag/removeHashtag?hashTagId=${hashTagId}`, {
      headers: getAuthHeaders()
    })

    return { ...response.data, hashTagId }
  } catch (error) {
    return thunkAPI.rejectWithValue(error.response?.data?.message || error.message)
  }
})

const initialState = {
  initialLoading: true,
  loading: false,
  hashtags: [],
  status: 'idle',
  error: null,
  page: 1,
  pageSize: 10,
  total: 0
}

const hashtagsSlice = createSlice({
  name: 'hashtags',
  initialState,
  reducers: {
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
      state.page = 1 // Reset to first page when changing page size
    }
  },
  extraReducers: builder => {
    // Fetch hashtags
    builder.addCase(fetchHashtags.pending, state => {
      state.initialLoading = true
    })
    builder.addCase(fetchHashtags.fulfilled, (state, action) => {
      state.initialLoading = false

      if (action.payload.status) {
        state.hashtags = action.payload.data
        state.total = action.payload.total || action.payload.data.length
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(fetchHashtags.rejected, (state, action) => {
      state.initialLoading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Create hashtag
    builder.addCase(createHashtag.pending, state => {
      state.loading = true
    })
    builder.addCase(createHashtag.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.hashtags = [...state.hashtags, action.payload.data]
        state.total += 1
        toast.success(action.payload.message || 'Hashtag created successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(createHashtag.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Update hashtag
    builder.addCase(updateHashtag.pending, state => {
      state.loading = true
    })
    builder.addCase(updateHashtag.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        const index = state.hashtags.findIndex(hashtag => hashtag._id === action.payload.data._id)

        if (index !== -1) {
          state.hashtags[index] = action.payload.data
        }

        toast.success(action.payload.message || 'Hashtag updated successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(updateHashtag.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })

    // Delete hashtag
    builder.addCase(deleteHashtag.pending, state => {
      state.loading = true
    })
    builder.addCase(deleteHashtag.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        state.hashtags = state.hashtags.filter(hashtag => hashtag._id !== action.payload.hashTagId)
        state.total -= 1
        toast.success(action.payload.message || 'Hashtag deleted successfully')
      } else {
        state.error = action.payload.message
        toast.error(action.payload.message)
      }
    })
    builder.addCase(deleteHashtag.rejected, (state, action) => {
      state.loading = false
      state.error = action.payload
      toast.error(action.payload)
    })
  }
})

export const { setPage, setPageSize } = hashtagsSlice.actions

export default hashtagsSlice.reducer
