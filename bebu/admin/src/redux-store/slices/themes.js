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

export const getAllThemes = createAsyncThunk('api/admin/theme/getThemes', async () => {
  const response = await axios.get(`${BASE_URL}/api/admin/theme/getThemes`, {
    headers: getAuthHeaders()
  })

  // console.log(response)

  return response.data.data
})

export const createTheme = createAsyncThunk('api/admin/theme/createTheme', async (body, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/theme/createTheme`, body, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error creating theme')

    return rejectWithValue(error.response.data)
  }
})

export const updateTheme = createAsyncThunk('api/admin/updateTheme', async ({ body, query }, { rejectWithValue }) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/theme/updateTheme?themeId=${query}`, body, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error updating theme')

    return rejectWithValue(error.response.data)
  }
})

export const deleteTheme = createAsyncThunk('api/admin/theme/deleteTheme', async (id, { rejectWithValue }) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/theme/deleteTheme?themeId=${id}`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error deleting theme')

    return rejectWithValue(error.response.data)
  }
})

export const toggleThemeActive = createAsyncThunk(
  'api/admin/theme/toggleThemeActive',
  async (id, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/theme/toggleThemeStatus?themeId=${id}`,
        {},
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error toggling theme active status')

      return rejectWithValue(error.response.data)
    }
  }
)

export const toggleThemeRecommendation = createAsyncThunk(
  'api/admin/theme/toggleThemeRecommendation',
  async (id, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/theme/toggleThemeRecommendation?themeId=${id}`,
        {},
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      console.error(error)
      toast.error('Error toggling theme recommendation status')

      return rejectWithValue(error.response.data)
    }
  }
)

const themeSlice = createSlice({
  name: 'theme',
  initialState: {
    themes: [],
    initialLoading: true,
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: builder => {
    builder

      //______________________________________________Fetch themes____________________________________________________________

      .addCase(getAllThemes.pending, state => {
        state.initialLoading = true
        state.error = null
      })
      .addCase(getAllThemes.fulfilled, (state, action) => {
        state.themes = action.payload
        state.initialLoading = false
      })
      .addCase(getAllThemes.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      //______________________________________________Create theme_______________________________________________________________

      .addCase(createTheme.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(createTheme.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.themes.unshift(action.payload.data)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createTheme.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      //_____________________________________________Update theme_______________________________________________________________

      .addCase(updateTheme.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(updateTheme.fulfilled, (state, action) => {
        if (action.payload.status) {
          // console.log(action.payload)
          toast.success(action.payload.message)
          const index = state.themes.findIndex(theme => theme._id === action.payload.data._id)

          if (index !== -1) {
            state.themes[index] = action.payload.data
          }
        } else {
          toast.error(action.payload.message)
        }

        state.loading = false
      })
      .addCase(updateTheme.rejected, (state, action) => {
        state.loading = false

        // state.error = action.payload
      })

      //_____________________________________________Delete theme_______________________________________________________________

      .addCase(deleteTheme.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(deleteTheme.fulfilled, (state, action) => {
        // console.log(action)

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.themes = state.themes.filter(theme => theme._id !== action.meta.arg)
          state.loading = false
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteTheme.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      //_____________________________________________Toggle theme active status_________________________________________________

      .addCase(toggleThemeActive.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(toggleThemeActive.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const index = state.themes.findIndex(theme => theme._id === action.meta.arg)

          if (index !== -1) {
            state.themes[index].isActive = !state.themes[index].isActive
          }
        }

        state.loading = false
      })
      .addCase(toggleThemeActive.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })

      //_____________________________________________Toggle theme recommendation status_________________________________________________

      .addCase(toggleThemeRecommendation.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(toggleThemeRecommendation.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const index = state.themes.findIndex(theme => theme._id === action.meta.arg)

          if (index !== -1) {
            state.themes[index].isRecommended = !state.themes[index].isRecommended
          }
        } else {
          toast.error(action.payload.message)
        }

        state.loading = false
      })
      .addCase(toggleThemeRecommendation.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message)
      })
  }
})

export default themeSlice.reducer
