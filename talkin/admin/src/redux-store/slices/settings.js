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

// Fetch settings
export const fetchSettings = createAsyncThunk('settings/getSettingsData', async () => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/setting/getSettingsData`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

// Update settings
export const updateSettings = createAsyncThunk('settings/updateSettings', async data => {
  try {
    const settingId = data._id || ''

    const response = await axios.patch(`${BASE_URL}/api/admin/setting/modifySetting?settingId=${settingId}`, data, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to update settings')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

// Toggle setting
export const toggleSetting = createAsyncThunk('settings/toggleAppSetting', async ({ settingId, type }) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/setting/toggleAppSetting?settingId=${settingId}&type=${type}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    if (!response.data.status) {
      throw new Error(response.data.message || 'Failed to toggle setting')
    }

    toast.success('Setting updated successfully')

    return { type, data: response.data.data }
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to toggle setting')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

// New actions
export const addProfilePhoto = createAsyncThunk('settings/addProfilePhoto', async formData => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/setting/updateProfilePhotoList`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    toast.success('Profile photos added successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to add profile photos')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

export const removeProfilePhoto = createAsyncThunk('settings/removeProfilePhoto', async formData => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/setting/updateProfilePhotoList`, formData, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    toast.success('Profile photo removed successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to remove profile photo')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

// Game related actions
export const addGame = createAsyncThunk('settings/addGame', async data => {
  try {
    const settingId = data.get('settingId')

    const response = await axios.patch(`${BASE_URL}/api/admin/setting/addGame?settingId=${settingId}`, data, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    toast.success('Game added successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to add game')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

export const updateGame = createAsyncThunk('settings/updateGame', async data => {
  try {
    const settingId = data.get('settingId')

    const response = await axios.patch(`${BASE_URL}/api/admin/setting/modifyGame?settingId=${settingId}`, data, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    toast.success('Game updated successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to update game')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

export const removeGame = createAsyncThunk('settings/removeGame', async ({ settingId, gameId }) => {
  try {
    const response = await axios.delete(
      `${BASE_URL}/api/admin/setting/removeGame?settingId=${settingId}&gameId=${gameId}`,
      {
        headers: getAuthHeaders()
      }
    )

    toast.success('Game removed successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to remove game')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

export const toggleGameStatus = createAsyncThunk('settings/toggleGameStatus', async ({ settingId, gameId }) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/setting/toggleGameStatus?settingId=${settingId}&gameId=${gameId}`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    toast.success('Game status updated successfully')

    return response.data
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Failed to toggle game status')

    return Promise.reject(error?.response?.data?.message || 'Something went wrong')
  }
})

const initialState = {
  settings: null,
  loading: false,
  error: null
}

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {},
  extraReducers: builder => {
    // Fetch settings
    builder.addCase(fetchSettings.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(fetchSettings.fulfilled, (state, action) => {
      state.loading = false
      state.settings = action.payload.data
    })
    builder.addCase(fetchSettings.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Update settings
    builder.addCase(updateSettings.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(updateSettings.fulfilled, (state, action) => {
      state.loading = false

      if (action.payload.status) {
        toast.success(action.payload.message)
        state.settings = action.payload.data
      } else {
        toast.error(action.payload.message || 'Failed to update settings')
      }
    })
    builder.addCase(updateSettings.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Toggle setting
    builder.addCase(toggleSetting.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(toggleSetting.fulfilled, (state, action) => {
      state.loading = false

      if (state.settings) {
        state.settings = {
          ...state.settings,
          [action.payload.type]: !state.settings[action.payload.type]
        }
      }
    })
    builder.addCase(toggleSetting.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Add profile photo
    builder.addCase(addProfilePhoto.fulfilled, (state, action) => {
      state.loading = false
      state.settings.profilePhotoList = action.payload.data
    })
    builder.addCase(addProfilePhoto.pending, state => {
      state.loading = true
    })
    builder.addCase(addProfilePhoto.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    builder.addCase(removeProfilePhoto.fulfilled, (state, action) => {
      state.loading = false
      state.settings.profilePhotoList = action.payload.data
    })
    builder.addCase(removeProfilePhoto.pending, state => {
      state.loading = true
    })
    builder.addCase(removeProfilePhoto.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Add Game
    builder.addCase(addGame.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(addGame.fulfilled, (state, action) => {
      state.loading = false

      if (state.settings && action.payload.status) {
        state.settings = action.payload.setting
      }
    })
    builder.addCase(addGame.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Update Game
    builder.addCase(updateGame.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(updateGame.fulfilled, (state, action) => {
      state.loading = false

      if (state.settings && action.payload.status) {
        state.settings = action.payload.setting
      }
    })
    builder.addCase(updateGame.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Remove Game
    builder.addCase(removeGame.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(removeGame.fulfilled, (state, action) => {
      state.loading = false

      if (state.settings && action.payload.status) {
        state.settings = action.payload.setting
      }
    })
    builder.addCase(removeGame.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })

    // Toggle Game Status
    builder.addCase(toggleGameStatus.pending, state => {
      state.loading = true
      state.error = null
    })
    builder.addCase(toggleGameStatus.fulfilled, (state, action) => {
      state.loading = false

      console.log(action.payload)

      if (state.settings && action.payload.status) {
        state.settings = action.payload.setting
      }
    })
    builder.addCase(toggleGameStatus.rejected, (state, action) => {
      state.loading = false
      state.error = action.error.message
    })
  }
})

export default settingsSlice.reducer
