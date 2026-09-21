import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/appearance`

const getAuthHeaders = () => {
  if (typeof window === 'undefined') return {}

  return {
    'Content-Type': 'application/json',
    key: secretKey,
    Authorization: `Bearer ${localStorage.getItem('admin_token')}`,
    'x-admin-uid': localStorage.getItem('uid')
  }
}

const fail = (error, fallback) => {
  const message = error?.response?.data?.message || error?.response?.data?.error || error?.message || fallback

  return Promise.reject(message)
}

export const fetchAppearance = createAsyncThunk('appearance/fetch', async () => {
  try {
    const { data } = await axios.get(API, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Failed to load appearance settings')
  }
})

export const updateAppearance = createAsyncThunk('appearance/update', async payload => {
  try {
    const { data } = await axios.patch(API, payload, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)
    toast.success(data.message || 'Appearance saved')

    return data.data
  } catch (error) {
    toast.error(error?.response?.data?.message || error.message || 'Failed to save appearance')

    return fail(error, 'Failed to save appearance')
  }
})

const appearanceSlice = createSlice({
  name: 'appearance',
  initialState: {
    loading: false,
    saving: false,
    error: null,
    settingId: null,
    appearance: null,
    options: { themes: [], accents: [], motion: [], cornerStyles: [] }
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchAppearance.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchAppearance.fulfilled, (state, action) => {
        state.loading = false
        state.settingId = action.payload.settingId
        state.appearance = action.payload.appearance
        state.options = action.payload.options
      })
      .addCase(fetchAppearance.rejected, (state, action) => {
        state.loading = false
        state.error = action.error?.message || 'Failed to load appearance settings'
      })
      .addCase(updateAppearance.pending, state => {
        state.saving = true
      })
      .addCase(updateAppearance.fulfilled, (state, action) => {
        state.saving = false
        state.appearance = action.payload
      })
      .addCase(updateAppearance.rejected, state => {
        state.saving = false
      })
  }
})

export default appearanceSlice.reducer
