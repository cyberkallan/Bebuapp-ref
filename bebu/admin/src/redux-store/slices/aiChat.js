import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/aiChat`

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

export const fetchAiConfig = createAsyncThunk('aiChat/fetchConfig', async () => {
  try {
    const { data } = await axios.get(`${API}/config`, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Failed to load AI settings')
  }
})

export const updateAiConfig = createAsyncThunk('aiChat/updateConfig', async payload => {
  try {
    const { data } = await axios.patch(`${API}/config`, payload, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)
    toast.success(data.message || 'AI settings saved')

    return data.data
  } catch (error) {
    toast.error(error?.response?.data?.message || error.message || 'Failed to save AI settings')

    return fail(error, 'Failed to save AI settings')
  }
})

export const testAiProvider = createAsyncThunk('aiChat/testProvider', async ({ provider, index }) => {
  try {
    const { data } = await axios.post(`${API}/testProvider`, { provider, index }, { headers: getAuthHeaders() })

    return { index, ...data }
  } catch (error) {
    return { index, status: false, message: error?.response?.data?.message || error.message }
  }
})

export const runAiPlayground = createAsyncThunk('aiChat/playground', async payload => {
  try {
    const { data } = await axios.post(`${API}/playground`, payload, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Generation failed')
  }
})

export const fetchAiUsage = createAsyncThunk('aiChat/fetchUsage', async (days = 14) => {
  try {
    const { data } = await axios.get(`${API}/usage`, { params: { days }, headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Failed to load AI usage')
  }
})

export const fetchListenerAiProfile = createAsyncThunk('aiChat/fetchListenerProfile', async listenerId => {
  try {
    const { data } = await axios.get(`${API}/listenerProfile`, { params: { listenerId }, headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)

    return data.data
  } catch (error) {
    return fail(error, 'Failed to load persona')
  }
})

export const updateListenerAiProfile = createAsyncThunk('aiChat/updateListenerProfile', async ({ listenerId, profile }) => {
  try {
    const { data } = await axios.patch(`${API}/listenerProfile`, profile, {
      params: { listenerId },
      headers: getAuthHeaders()
    })

    if (!data.status) throw new Error(data.message)
    toast.success(data.message || 'Persona saved')

    return data.data
  } catch (error) {
    toast.error(error?.response?.data?.message || error.message || 'Failed to save persona')

    return fail(error, 'Failed to save persona')
  }
})

export const assignAiLanguage = createAsyncThunk('aiChat/assignLanguage', async payload => {
  try {
    const { data } = await axios.post(`${API}/assignLanguage`, payload, { headers: getAuthHeaders() })

    if (!data.status) throw new Error(data.message)
    toast.success(data.message)

    return data.data
  } catch (error) {
    toast.error(error?.response?.data?.message || error.message || 'Failed to assign language')

    return fail(error, 'Failed to assign language')
  }
})

const initialState = {
  settingId: '',
  aiChat: null,
  languages: [],
  tones: [],
  presets: [],
  cooldowns: {},
  usage: null,
  loading: false,
  saving: false,
  usageLoading: false,
  playgroundLoading: false,
  playgroundResult: null,
  playgroundError: '',
  providerTests: {},
  error: ''
}

const aiChatSlice = createSlice({
  name: 'aiChat',
  initialState,
  reducers: {
    clearPlayground: state => {
      state.playgroundResult = null
      state.playgroundError = ''
    },
    clearProviderTest: (state, action) => {
      delete state.providerTests[action.payload]
    }
  },
  extraReducers: builder => {
    builder
      .addCase(fetchAiConfig.pending, state => {
        state.loading = true
        state.error = ''
      })
      .addCase(fetchAiConfig.fulfilled, (state, action) => {
        state.loading = false
        state.settingId = action.payload.settingId
        state.aiChat = action.payload.aiChat
        state.languages = action.payload.languages
        state.tones = action.payload.tones
        state.presets = action.payload.presets
        state.cooldowns = action.payload.cooldowns || {}
      })
      .addCase(fetchAiConfig.rejected, (state, action) => {
        state.loading = false
        state.error = action.error?.message || 'Failed to load AI settings'
      })
      .addCase(updateAiConfig.pending, state => {
        state.saving = true
      })
      .addCase(updateAiConfig.fulfilled, (state, action) => {
        state.saving = false
        state.aiChat = action.payload
      })
      .addCase(updateAiConfig.rejected, state => {
        state.saving = false
      })
      .addCase(testAiProvider.pending, (state, action) => {
        state.providerTests[action.meta.arg.index] = { loading: true }
      })
      .addCase(testAiProvider.fulfilled, (state, action) => {
        const { index, status, message, data } = action.payload

        state.providerTests[index] = { loading: false, ok: status, message, ...(data || {}) }
      })
      .addCase(runAiPlayground.pending, state => {
        state.playgroundLoading = true
        state.playgroundError = ''
      })
      .addCase(runAiPlayground.fulfilled, (state, action) => {
        state.playgroundLoading = false
        state.playgroundResult = action.payload
      })
      .addCase(runAiPlayground.rejected, (state, action) => {
        state.playgroundLoading = false
        state.playgroundError = action.error?.message || 'Generation failed'
      })
      .addCase(fetchAiUsage.pending, state => {
        state.usageLoading = true
      })
      .addCase(fetchAiUsage.fulfilled, (state, action) => {
        state.usageLoading = false
        state.usage = action.payload
        state.cooldowns = action.payload.cooldowns || {}
      })
      .addCase(fetchAiUsage.rejected, state => {
        state.usageLoading = false
      })
  }
})

export const { clearPlayground, clearProviderTest } = aiChatSlice.actions
export default aiChatSlice.reducer
