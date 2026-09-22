import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/gift`

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

const toForm = fields => {
  const form = new FormData()

  Object.entries(fields).forEach(([k, v]) => {
    if (v === undefined || v === null) return
    form.append(k, v)
  })

  return form
}

export const fetchGiftCatalog = createAsyncThunk('giftCatalog/fetch', async () => {
  const data = await run(() => axios.get(API, { headers: headers() }), 'Failed to load gifts', false)

  return data.data
})

export const updateGiftSettings = createAsyncThunk('giftCatalog/settings', async payload => {
  const data = await run(() => axios.patch(`${API}/settings`, payload, { headers: headers() }), 'Failed to save gift settings')

  return data.data
})

export const addGift = createAsyncThunk('giftCatalog/add', async fields => {
  const data = await run(() => axios.post(API, toForm(fields), { headers: headers(false) }), 'Failed to add gift')

  return data.data
})

export const editGift = createAsyncThunk('giftCatalog/edit', async ({ giftId, ...fields }) => {
  const data = await run(() => axios.patch(`${API}?giftId=${giftId}`, toForm(fields), { headers: headers(false) }), 'Failed to update gift')

  return data.data
})

export const toggleGift = createAsyncThunk('giftCatalog/toggle', async giftId => {
  const data = await run(() => axios.patch(`${API}/toggle?giftId=${giftId}`, {}, { headers: headers() }), 'Failed to toggle gift')

  return data.data
})

export const reorderGifts = createAsyncThunk('giftCatalog/reorder', async order => {
  await run(() => axios.patch(`${API}/reorder`, { order }, { headers: headers() }), 'Failed to save order', false)

  return order
})

export const deleteGift = createAsyncThunk('giftCatalog/delete', async giftId => {
  await run(() => axios.delete(`${API}?giftId=${giftId}`, { headers: headers() }), 'Failed to delete gift')

  return giftId
})

const upsert = (state, gift) => {
  const i = state.gifts.findIndex(x => x._id === gift._id)

  if (i === -1) state.gifts.push(gift)
  else state.gifts[i] = gift
}

const giftCatalogSlice = createSlice({
  name: 'giftCatalog',
  initialState: {
    loading: false,
    saving: false,
    settings: null,
    gifts: [],
    stats: { sent7d: 0, coins7d: 0, hostCoins7d: 0, platformCoins7d: 0, senders7d: 0, topGift: '', active: 0, total: 0 }
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchGiftCatalog.pending, state => {
        state.loading = true
      })
      .addCase(fetchGiftCatalog.fulfilled, (state, action) => {
        state.loading = false
        state.settings = action.payload.settings
        state.gifts = action.payload.gifts
        state.stats = action.payload.stats
      })
      .addCase(fetchGiftCatalog.rejected, state => {
        state.loading = false
      })
      .addCase(updateGiftSettings.pending, state => {
        state.saving = true
      })
      .addCase(updateGiftSettings.fulfilled, (state, action) => {
        state.saving = false
        state.settings = action.payload
      })
      .addCase(updateGiftSettings.rejected, state => {
        state.saving = false
      })
      .addCase(addGift.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(editGift.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(toggleGift.fulfilled, (state, action) => upsert(state, action.payload))
      .addCase(reorderGifts.fulfilled, (state, action) => {
        action.payload.forEach((id, i) => {
          const g = state.gifts.find(x => x._id === id)

          if (g) g.sortOrder = i + 1
        })
      })
      .addCase(deleteGift.fulfilled, (state, action) => {
        state.gifts = state.gifts.filter(x => x._id !== action.payload)
      })
  }
})

export default giftCatalogSlice.reducer
