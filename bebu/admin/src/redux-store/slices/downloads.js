import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const API = `${baseURL}/api/admin/download`

const headers = () => {
  if (typeof window === 'undefined') return {}

  return {
    key: secretKey,
    Authorization: `Bearer ${localStorage.getItem('admin_token')}`,
    'x-admin-uid': localStorage.getItem('uid')
  }
}

const msg = (error, fallback) => error?.response?.data?.message || error?.message || fallback

export const fetchDownloads = createAsyncThunk('downloads/fetch', async (_, { rejectWithValue }) => {
  try {
    const { data } = await axios.get(API, { headers: headers() })

    if (!data.status) throw new Error(data.message)

    return data
  } catch (error) {
    const m = msg(error, 'Could not load downloads')

    toast.error(m)

    return rejectWithValue(m)
  }
})

// Ask the backend for a short-lived signed URL, then let the browser download it.
export const startDownload = createAsyncThunk('downloads/start', async (name, { rejectWithValue }) => {
  try {
    const { data } = await axios.get(`${API}/link`, { params: { name }, headers: headers() })

    if (!data.status) throw new Error(data.message)
    const url = `${baseURL}${data.url}`
    const a = document.createElement('a')

    a.href = url
    a.download = name
    a.rel = 'noopener'
    document.body.appendChild(a)
    a.click()
    a.remove()

    return name
  } catch (error) {
    const m = msg(error, 'Could not start the download')

    toast.error(m)

    return rejectWithValue(m)
  }
})

const downloadsSlice = createSlice({
  name: 'downloads',
  initialState: { files: [], dir: '', status: 'idle', error: null, starting: null },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchDownloads.pending, state => {
        state.status = 'loading'
        state.error = null
      })
      .addCase(fetchDownloads.fulfilled, (state, action) => {
        state.status = 'succeeded'
        state.files = action.payload.files || []
        state.dir = action.payload.dir || ''
      })
      .addCase(fetchDownloads.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.payload
      })
      .addCase(startDownload.pending, (state, action) => {
        state.starting = action.meta.arg
      })
      .addCase(startDownload.fulfilled, state => {
        state.starting = null
      })
      .addCase(startDownload.rejected, state => {
        state.starting = null
      })
  }
})

export default downloadsSlice.reducer
