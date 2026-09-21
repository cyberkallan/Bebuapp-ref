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

export const getAllLevels = createAsyncThunk('wealthLevels/getAll', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/wealthLevel/getWealthLevels`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

export const createWealthLevel = createAsyncThunk('wealthLevels/create', async (formData, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/wealthLevel/createWealthLevel`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (err) {
    toast.error('Failed to create wealth level')

    return rejectWithValue(err.response?.data || err.message)
  }
})

export const editWealthLevel = createAsyncThunk('wealthLevels/edit', async ({ id, formData }, { rejectWithValue }) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/wealthLevel/updateWealthLevel?levelId=${id}`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (err) {
    return rejectWithValue(err.response?.data?.message || err.message)
  }
})

export const updateWealthLevelPermissions = createAsyncThunk(
  'api/admin/wealthLevel/updateWealthLevelPermissions',
  async (permissionsData, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/wealthLevel/updateWealthLevelPermissions`,
        permissionsData,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: 'Failed to update permissions' })
    }
  }
)

export const deleteWealthLevel = createAsyncThunk('wealthLevels/delete', async (id, { rejectWithValue }) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/wealthLevel/deleteWealthLevel?levelId=${id}`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (err) {
    return rejectWithValue(err.response?.data?.message || err.message)
  }
})

const wealthLevelSlice = createSlice({
  name: 'wealthLevels',
  initialState: {
    levels: [],
    initialLoading: true,
    loading: false,
    error: null,
    updateStatus: {
      loading: false,
      success: false,
      error: null
    }
  },
  reducers: {
    resetUpdateStatus: state => {
      state.updateStatus = {
        loading: false,
        success: false,
        error: null
      }
    }
  },
  extraReducers: builder => {
    //______________________________________________________________Fetch levels________________________________________________
    builder
      .addCase(getAllLevels.pending, state => {
        state.initialLoading = true
      })
      .addCase(getAllLevels.fulfilled, (state, action) => {
        state.initialLoading = false
        state.levels = action.payload.data
      })
      .addCase(getAllLevels.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload)
      })

      //______________________________________________________________Create level________________________________________________
      .addCase(createWealthLevel.pending, state => {
        state.loading = true
      })
      .addCase(createWealthLevel.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.levels.unshift(action.payload.data)
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createWealthLevel.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

    //______________________________________________________________update permissions________________________________________________
    builder.addCase(updateWealthLevelPermissions.pending, state => {
      state.updateStatus.loading = true
      state.updateStatus.success = false
      state.updateStatus.error = null
    })
    builder.addCase(updateWealthLevelPermissions.fulfilled, (state, action) => {
      state.updateStatus.loading = false
      state.updateStatus.success = true

      // Optionally update the level in the state to avoid refetching
      const updatedLevel = action.payload

      if (updatedLevel && updatedLevel._id) {
        const levelIndex = state.levels.findIndex(level => level._id === updatedLevel._id)

        if (levelIndex !== -1) {
          state.levels[levelIndex] = {
            ...state.levels[levelIndex],
            permissions: updatedLevel.permissions
          }
        }
      }
    })
    builder.addCase(updateWealthLevelPermissions.rejected, (state, action) => {
      state.updateStatus.loading = false
      state.updateStatus.error = action.payload
    })

    //______________________________________________________________Edit level________________________________________________
    builder
      .addCase(editWealthLevel.pending, state => {
        state.loading = true
      })
      .addCase(editWealthLevel.fulfilled, (state, action) => {
        state.loading = false
        const updatedId = action.meta.arg.id
        const updatedFields = action.payload?.data || {}

        if (action.payload.status) {
          state.levels = state.levels.map(level => {
            if (level._id === updatedId) {
              return {
                ...level,
                level: updatedFields.level !== undefined ? updatedFields.level : level.level,
                levelName: updatedFields.levelName !== undefined ? updatedFields.levelName : level.levelName,
                coinThreshold:
                  updatedFields.coinThreshold !== undefined ? updatedFields.coinThreshold : level.coinThreshold,
                levelImage: updatedFields.levelImage !== undefined ? updatedFields.levelImage : level.levelImage
              }
            }

            return level
          })

          toast.success(action.payload.message || 'Level updated')
        } else {
          toast.error(action.payload.message || 'Update failed')
        }
      })

      .addCase(editWealthLevel.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message || 'Update error')
      })

      //______________________________________________________________Delete level________________________________________________
      .addCase(deleteWealthLevel.pending, state => {
        state.loading = true
      })
      .addCase(deleteWealthLevel.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message || 'Deleted successfully')
          state.levels = state.levels.filter(level => level._id !== action.meta.arg)
        } else {
          toast.error(action.payload.message || 'Delete failed')
        }
      })
      .addCase(deleteWealthLevel.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        toast.error(action.payload.message || 'Delete error')
      })
  }
})

export const { resetUpdateStatus } = wealthLevelSlice.actions
export default wealthLevelSlice.reducer
