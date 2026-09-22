import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/loginRewards`

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

export const fetchLoginRewards = createAsyncThunk('loginRewards/fetch', async () => {
  try {
    const { data } = await axios.get(API, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Failed to load login & rewards settings')
  }
})

export const updateLoginRewards = createAsyncThunk('loginRewards/update', async payload => {
  try {
    const { data } = await axios.patch(API, payload, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)
    toast.success(data.message || 'Saved')

    return data.data
  } catch (error) {
    toast.error(error?.response?.data?.message || error.message || 'Failed to save')

    return fail(error, 'Failed to save')
  }
})

const loginRewardsSlice = createSlice({
  name: 'loginRewards',
  initialState: {
    loading: false,
    saving: false,
    error: null,
    settingId: null,
    login: null,
    preset: 'custom',
    dailyReward: null,
    rewards: null,
    welcomeCoins: 0,
    options: { methods: [], presets: [] },
    stats: null
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchLoginRewards.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchLoginRewards.fulfilled, (state, action) => {
        const p = action.payload

        state.loading = false
        state.settingId = p.settingId
        state.login = p.login
        state.preset = p.preset
        state.dailyReward = p.dailyReward
        state.rewards = p.rewards || state.rewards
        state.welcomeCoins = p.welcomeCoins
        state.options = p.options
        state.stats = p.stats
      })
      .addCase(fetchLoginRewards.rejected, (state, action) => {
        state.loading = false
        state.error = action.error?.message || 'Failed to load login & rewards settings'
      })
      .addCase(updateLoginRewards.pending, state => {
        state.saving = true
      })
      .addCase(updateLoginRewards.fulfilled, (state, action) => {
        const p = action.payload

        state.saving = false
        state.login = p.login
        state.preset = p.preset
        state.dailyReward = p.dailyReward
        state.rewards = p.rewards || state.rewards
        state.welcomeCoins = p.welcomeCoins
      })
      .addCase(updateLoginRewards.rejected, state => {
        state.saving = false
      })
  }
})

export default loginRewardsSlice.reducer
