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

// Thunk actions for categories
export const fetchCategories = createAsyncThunk('songs/fetchCategories', async ({ start, limit }) => {
  try {
    const response = await axios.get(
      `${BASE_URL}/api/admin/songCategory/fetchAllSongCategories?start=${start}&limit=${limit}`,
      {
        headers: getAuthHeaders()
      }
    )

    return response.data
  } catch (error) {
    console.log(error)
    console.error(error)
    toast.error('Error fetching categories')

    // return rejectWithValue(error.response.data)
  }
})

export const createCategory = createAsyncThunk('songs/createCategory', async formData => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/songCategory/createSongCategory`, formData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error creating category')

    // return rejectWithValue(error.response.data)
  }
})

export const updateCategory = createAsyncThunk('songs/updateCategory', async formData => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/songCategory/modifySongCategory`, formData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error updating category')

    // return rejectWithValue(error.response.data)
  }
})

export const deleteCategory = createAsyncThunk('songs/deleteCategory', async songCategoryId => {
  try {
    const response = await axios.delete(
      `${BASE_URL}/api/admin/songCategory/removeSongCategory?songCategoryId=${songCategoryId}`,
      {
        headers: getAuthHeaders()
      }
    )

    return { songCategoryId, ...response.data }
  } catch (error) {
    console.error(error)
    toast.error('Error delete category')

    // return rejectWithValue(error.response.data)
  }
})

// Thunk actions for songs
export const fetchSongs = createAsyncThunk('songs/fetchSongs', async ({ start, limit, startDate, endDate }) => {
  try {
    const response = await axios.get(
      `${BASE_URL}/api/admin/song/fetchSongs?start=${start}&limit=${limit}&startDate=${startDate}&endDate=${endDate}`,
      {
        headers: getAuthHeaders()
      }
    )

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error fetching song')

    // return rejectWithValue(error.response.data)
  }
})

export const createSong = createAsyncThunk('songs/createSong', async formData => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/song/addSong`, formData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error creating song')

    // return rejectWithValue(error.response.data)
  }
})

export const updateSong = createAsyncThunk('songs/updateSong', async formData => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/song/modifySong`, formData, {
      headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
    })

    return response.data
  } catch (error) {
    console.error(error)
    toast.error('Error updating song')

    // return rejectWithValue(error.response.data)
  }
})

export const deleteSong = createAsyncThunk('songs/deleteSong', async songId => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/song/removeSong?songId=${songId}`, {
      headers: getAuthHeaders()
    })

    return { songId, ...response.data }
  } catch (error) {
    console.error(error)
    toast.error('Error delete song')

    // return rejectWithValue(error.response.data)
  }
})

const initialState = {
  // Categories state
  categories: [],
  categoryTotal: 0,
  categoryPage: 1,
  categoryPageSize: 10,
  categoryLoading: false,
  categoryInitialLoading: true,

  // Songs state
  songs: [],
  songTotal: 0,
  songPage: 1,
  songPageSize: 10,
  startDate: 'All',
  endDate: 'All',
  songLoading: false,
  songInitialLoading: true,

  // Common state
  error: null
}

const songsSlice = createSlice({
  name: 'song',
  initialState,
  reducers: {
    setCategoryPage: (state, action) => {
      state.categoryPage = action.payload
    },
    setCategoryPageSize: (state, action) => {
      state.categoryPageSize = action.payload
    },
    setSongPage: (state, action) => {
      state.songPage = action.payload
    },
    setSongPageSize: (state, action) => {
      state.songPageSize = action.payload
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
    }
  },
  extraReducers: builder => {
    // Category reducers
    builder
      .addCase(fetchCategories.pending, state => {
        state.categoryLoading = true
      })
      .addCase(fetchCategories.fulfilled, (state, action) => {
        console.log(action)

        if (action.payload.status) {
          state.categories = action.payload.categories
          state.categoryTotal = action.payload.total
          state.categoryLoading = false
          state.categoryInitialLoading = false
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchCategories.rejected, (state, action) => {
        state.categoryLoading = false
        state.categoryInitialLoading = false
        state.error = action.error.message
        toast.error(action.payload.message)
      })
      .addCase(createCategory.fulfilled, (state, action) => {
        if (action.payload.message) {
          state.categories.push(action.payload.songCategory)
          state.categoryTotal += 1
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createCategory.rejected, (state, action) => {
        toast.error(action.payload.message)
      })
      .addCase(updateCategory.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const index = state.categories.findIndex(cat => cat._id === action.payload.songCategory._id)

          if (index !== -1) {
            state.categories[index] = action.payload.songCategory
          }
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteCategory.fulfilled, (state, action) => {
        if (action.payload.message) {
          state.categories = state.categories.filter(cat => cat._id !== action.meta.arg)
          state.categoryTotal -= 1
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(deleteCategory.rejected, (state, action) => {
        toast.error(action.payload.message)
      })

    // Song reducers
    builder
      .addCase(fetchSongs.pending, state => {
        state.songLoading = true
      })
      .addCase(fetchSongs.fulfilled, (state, action) => {
        if (action.payload.message) {
          state.songs = action.payload.data
          state.songTotal = action.payload.total
          state.songLoading = false
          state.songInitialLoading = false
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchSongs.rejected, (state, action) => {
        state.songLoading = false
        state.songInitialLoading = false
        state.error = action.error.message
        toast.error(action.payload.message)
      })
      .addCase(createSong.fulfilled, (state, action) => {
        if (action.payload.status) {
          state.songs.unshift({
            ...action.payload.data,
            songCategoryId: action.payload.data.songCategory // ensure normalized category
          })
          state.songTotal += 1
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(createSong.rejected, (state, action) => {
        toast.error(action.payload.message)
      })
      .addCase(updateSong.fulfilled, (state, action) => {
        toast.success(action.payload.message)

        if (action.payload.message) {
          const index = state.songs.findIndex(song => song._id === action.payload.data._id)

          if (index !== -1) {
            state.songs[index] = {
              ...action.payload.data,
              songCategoryId: action.payload.data.songCategory // normalize for consistency
            }
          }
        } else {
          toast.error(action.payload.message)
        }
      })
      .addCase(updateSong.rejected, (state, action) => {
        toast.error(action.payload.message)
      })
      .addCase(deleteSong.fulfilled, (state, action) => {
        if (action.payload.message) {
          state.songs = state.songs.filter(song => song._id !== action.meta.arg)
          state.songTotal -= 1
          toast.success(action.payload.message)
        } else {
          toast.error(action.payload.message)
        }
      })
  }
})

export const { setCategoryPage, setCategoryPageSize, setSongPage, setSongPageSize, setDateRange } = songsSlice.actions

export default songsSlice.reducer
