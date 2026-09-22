import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

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

export const getAllFrames = createAsyncThunk('api/admin/avtarFrame/getAvtarFrames', async () => {
  const response = await axios.get(`${BASE_URL}/api/admin/avtarFrame/getAvtarFrames`, {
    headers: getAuthHeaders()
  })

  return response.data
})

export const createFrame = createAsyncThunk(
  'api/admin/avtarFrame/createAvtarFrame',
  async (body, { rejectWithValue }) => {
    try {
      const response = await axios.post(`${BASE_URL}/api/admin/avtarFrame/createAvtarFrame`, body, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        }
      })

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error creating frame')

      return rejectWithValue(error.response.data)
    }
  }
)

export const deleteFrame = createAsyncThunk(
  'api/admin/avtarFrame/deleteAvtarFrame',
  async (frameId, { rejectWithValue }) => {
    try {
      const response = await axios.delete(`${BASE_URL}/api/admin/avtarFrame/deleteAvtarFrame?frameId=${frameId}`, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error deleting frame')

      return rejectWithValue(error.response.data)
    }
  }
)

export const updateFrame = createAsyncThunk(
  'api/admin/avtarFrame/updateAvtarFrame',
  async ({ body, query }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${BASE_URL}/api/admin/avtarFrame/updateAvtarFrame?frameId=${query}`, body, {
        headers: {
          ...getAuthHeaders(),
          'Content-Type': 'multipart/form-data'
        }
      })

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error updating frame')

      return rejectWithValue(error.response.data)
    }
  }
)

export const toggleFrameActive = createAsyncThunk('api/admin/avtarFrame/toggleAvtarFrameStatus', async frameId => {
  const response = await axios.patch(
    `${BASE_URL}/api/admin/avtarFrame/toggleAvtarFrameStatus?avtarFrameId=${frameId}`,
    {},
    {
      headers: getAuthHeaders()
    }
  )

  return response.data
})

export const toggleFrameRecommendation = createAsyncThunk(
  'api/admin/avtarFrame/toggleAvtarFrameRecommendation',
  async frameId => {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/avtarFrame/toggleAvtarFrameRecommendation?avtarFrameId=${frameId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    return response.data
  }
)

export const framesSlice = createSlice({
  name: 'frames',
  initialState: {
    frames: [],
    initialLoading: true,
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: builder => {
    //______________________________________________Fetch frames____________________________________________________________
    builder
      .addCase(getAllFrames.pending, state => {
        state.initialLoading = true
      })
      .addCase(getAllFrames.fulfilled, (state, action) => {
        state.initialLoading = false

        if (action.payload.status) {
          state.frames = action.payload.data
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(getAllFrames.rejected, (state, action) => {
        state.loading = false
        state.initialLoading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

    //______________________________________________Create frame_______________________________________________________________
    builder
      .addCase(createFrame.pending, state => {
        state.loading = true
      })
      .addCase(createFrame.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.frames.unshift(action.payload.data)
          state.error = null
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createFrame.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload.message
        toast.error(action.payload.message)
      })

    //______________________________________________Delete frame_______________________________________________________________
    builder
      .addCase(deleteFrame.pending, state => {
        state.loading = true
      })
      .addCase(deleteFrame.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.error = null
          state.frames = state.frames.filter(frame => frame._id !== action.meta.arg)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteFrame.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload.message
        toast.error(action.payload.message)
      })

    // ___________________________________ Update frame _______________________________________
    builder
      .addCase(updateFrame.pending, state => {
        state.loading = true
      })
      .addCase(updateFrame.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.frames = state.frames.map(frame =>
            frame._id === action.payload.data._id ? action.payload.data : frame
          )
          toast.success(action.payload.message)
          state.error = null
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(updateFrame.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload.message
        toast.error(action.payload.message)
      })

    // _________________________________ Toggle isActive _______________________________________
    builder.addCase(toggleFrameActive.fulfilled, (state, action) => {
      if (action.payload.status) {
        const frame = state.frames.find(f => f._id === action.meta.arg)

        if (frame) frame.isActive = !frame.isActive
        toast.success(action.payload.message)
      } else {
        toast.error(action.payload.message)
      }
    })

    // _________________________________ Toggle isRecommended _________________________________
    builder.addCase(toggleFrameRecommendation.fulfilled, (state, action) => {
      if (action.payload.status) {
        const frame = state.frames.find(f => f._id === action.meta.arg)

        if (frame) frame.isRecommended = !frame.isRecommended
        toast.success(action.payload.message)
      } else {
        toast.error(action.payload.message)
      }
    })
  }
})

export default framesSlice.reducer
