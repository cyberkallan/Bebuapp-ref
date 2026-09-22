import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/avatarStudio`

const headers = (json = true) => {
  if (typeof window === 'undefined') return {}

  return {
    ...(json ? { 'Content-Type': 'application/json' } : {}),
    key: secretKey,
    Authorization: `Bearer ${localStorage.getItem('admin_token')}`,
    'x-admin-uid': localStorage.getItem('uid')
  }
}

const msg = (error, fallback) => error?.response?.data?.message || error?.response?.data?.error || error?.message || fallback

const run = async (fn, fallback, successToast = true) => {
  try {
    const { data } = await fn()

    if (!data.status) throw new Error(data.message)
    if (successToast && data.message) toast.success(data.message)

    return data
  } catch (error) {
    toast.error(msg(error, fallback))

    return Promise.reject(msg(error, fallback))
  }
}

export const fetchAvatarStudio = createAsyncThunk('avatarStudio/fetch', async () => {
  const data = await run(() => axios.get(API, { headers: headers() }), 'Failed to load Avatar Studio', false)

  return data.data
})

export const updateAvatarStudioSettings = createAsyncThunk('avatarStudio/settings', async payload => {
  const data = await run(() => axios.patch(`${API}/settings`, payload, { headers: headers() }), 'Failed to save settings')

  return data.data
})

const toForm = fields => {
  const form = new FormData()

  Object.entries(fields).forEach(([k, v]) => {
    if (v === undefined || v === null) return
    form.append(k, v)
  })

  return form
}

export const addAvatarItem = createAsyncThunk('avatarStudio/add', async fields => {
  const data = await run(() => axios.post(`${API}/item`, toForm(fields), { headers: headers(false) }), 'Failed to add item')

  return data.data
})

export const editAvatarItem = createAsyncThunk('avatarStudio/edit', async ({ itemId, ...fields }) => {
  const data = await run(() => axios.patch(`${API}/item?itemId=${itemId}`, toForm(fields), { headers: headers(false) }), 'Failed to update item')

  return data.data
})

export const toggleAvatarItem = createAsyncThunk('avatarStudio/toggle', async itemId => {
  const data = await run(() => axios.patch(`${API}/item/toggle?itemId=${itemId}`, {}, { headers: headers() }), 'Failed to toggle item')

  return data.data
})

export const deleteAvatarItem = createAsyncThunk('avatarStudio/delete', async itemId => {
  await run(() => axios.delete(`${API}/item?itemId=${itemId}`, { headers: headers() }), 'Failed to delete item')

  return itemId
})

const upsert = (state, item) => {
  const i = state.items.findIndex(x => x._id === item._id)

  if (i === -1) state.items.push(item)
  else state.items[i] = item
}

const avatarStudioSlice = createSlice({
  name: 'avatarStudio',
  initialState: {
    loading: false,
    saving: false,
    settings: null,
    items: [],
    stats: { usingAvatar: 0, unlocks: 0, items: 0 },
    options: { categories: [], rarities: [], genders: [] }
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchAvatarStudio.pending, state => {
        state.loading = true
      })
      .addCase(fetchAvatarStudio.fulfilled, (state, action) => {
        state.loading = false
        state.settings = action.payload.settings
        state.items = action.payload.items
        state.stats = action.payload.stats
        state.options = action.payload.options
      })
      .addCase(fetchAvatarStudio.rejected, state => {
        state.loading = false
      })
      .addCase(updateAvatarStudioSettings.pending, state => {
        state.saving = true
      })
      .addCase(updateAvatarStudioSettings.fulfilled, (state, action) => {
        state.saving = false
        state.settings = action.payload
      })
      .addCase(updateAvatarStudioSettings.rejected, state => {
        state.saving = false
      })
      .addCase(addAvatarItem.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(editAvatarItem.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(toggleAvatarItem.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(deleteAvatarItem.fulfilled, (state, action) => {
        state.items = state.items.filter(x => x._id !== action.payload)
      })
  }
})

export default avatarStudioSlice.reducer
