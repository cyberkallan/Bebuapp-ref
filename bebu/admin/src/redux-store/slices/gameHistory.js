import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

const BASE_URL = baseURL

// Game type constants
export const GAME_TYPES = {
  TEENPATTI_GAME: 12,
  FERRYWHEEL_GAME: 13,
  CASINO_GAME: 14
}

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

// Fetch game records
export const fetchGameRecords = createAsyncThunk(
  'gameHistory/fetchGameRecords',
  async (
    { gameType = GAME_TYPES.TEENPATTI_GAME, startDate = 'All', endDate = 'All', start = 1, limit = 20 },
    thunkAPI
  ) => {
    try {
      const response = await axios.get(
        `${BASE_URL}/api/admin/history/fetchgameRecords?start=${start}&limit=${limit}&startDate=${startDate}&endDate=${endDate}&gameType=${gameType}`,
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Reset admin coins
export const resetGameAdminCoins = createAsyncThunk('gameHistory/resetGameAdminCoins', async (_, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/gameadminCoin/resetGameAdminCoins`,
      {},
      {
        headers: getAuthHeaders()
      }
    )

    toast.success(response.data.message || 'Admin coins reset successfully')

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  gameHistories: [],
  adminCoin: 0,
  total: 0,
  loading: false,
  error: null,
  currentGameType: GAME_TYPES.TEENPATTI_GAME
}

const gameHistorySlice = createSlice({
  name: 'gameHistory',
  initialState,
  reducers: {
    setCurrentGameType: (state, action) => {
      state.currentGameType = action.payload
    }
  },
  extraReducers: builder => {
    builder

      // Fetch game records
      .addCase(fetchGameRecords.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(fetchGameRecords.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.gameHistories = action.payload.gameHistories || []
          state.adminCoin = action.payload.adminCoin || 0
          state.total = action.payload.total || 0
        } else {
          state.error = action.payload.message
        }
      })
      .addCase(fetchGameRecords.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Reset admin coins
      .addCase(resetGameAdminCoins.pending, state => {
        state.loading = true
      })
      .addCase(resetGameAdminCoins.fulfilled, (state, action) => {
        state.loading = false

        // Refresh admin coin value if available in response
        if (action.payload?.adminCoin) {
          state.adminCoin = action.payload.adminCoin
        }
      })
      .addCase(resetGameAdminCoins.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
  }
})

export const { setCurrentGameType } = gameHistorySlice.actions

export default gameHistorySlice.reducer
