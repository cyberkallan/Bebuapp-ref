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

export const getAllReactions = createAsyncThunk('api/admin/reaction/getAllReactions', async () => {
  const response = await axios.get(`${BASE_URL}/api/admin/reaction/getAllReactions`, {
    headers: getAuthHeaders()
  })

  return response.data.data
})

export const createReaction = createAsyncThunk('api/admin/reaction/addReaction', async (body, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/reaction/addReaction`, body, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error creating reaction')

    return rejectWithValue(error.response.data)
  }
})

export const updateReaction = createAsyncThunk(
  'api/admin/reaction/updateReaction',
  async (body, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/reaction/updateReaction`, body, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        }
      })

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error updating reaction')

      return rejectWithValue(error.response.data)
    }
  }
)

export const deleteReaction = createAsyncThunk(
  'api/admin/reaction/deleteReaction',
  async (reactionId, { rejectWithValue }) => {
    try {
      const response = await axios.delete(`${BASE_URL}/api/admin/reaction/deleteReaction?reactionId=${reactionId}`, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error deleting reaction')

      return rejectWithValue(error.response.data)
    }
  }
)

const reactionSlice = createSlice({
  name: 'reaction',
  initialState: {
    reactions: [],
    initialLoading: true,
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: builder => {
    builder

      // Get all reactions
      .addCase(getAllReactions.pending, state => {
        state.initialLoading = true
        state.error = null
      })
      .addCase(getAllReactions.fulfilled, (state, action) => {
        state.reactions = action.payload
        state.initialLoading = false
      })
      .addCase(getAllReactions.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Create reaction
      .addCase(createReaction.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(createReaction.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.reactions.unshift(action.payload.data)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createReaction.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      // Update reaction
      .addCase(updateReaction.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(updateReaction.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const index = state.reactions.findIndex(reaction => reaction._id === action.payload.data._id)

          if (index !== -1) {
            state.reactions[index] = action.payload.data
          }
        } else {
          toast.error(action.payload.message)
        }

        state.loading = false
      })
      .addCase(updateReaction.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Delete reaction
      .addCase(deleteReaction.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(deleteReaction.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.reactions = state.reactions.filter(reaction => reaction._id !== action.meta.arg)
          state.loading = false
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteReaction.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })
  }
})

export default reactionSlice.reducer
