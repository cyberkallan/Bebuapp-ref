import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'
import { toast } from 'react-toastify'

import { secretKey, baseURL } from '@/config'

// Helpers
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

// Fetch all coin traders
export const fetchCoinTraders = createAsyncThunk('coinTrader/fetchAllCoinTraders', async (params = {}, thunkAPI) => {
  try {
    const result = await axios.get(`${baseURL}/api/admin/cointrader/getAllCoinTraders`, {
      headers: getAuthHeaders(),
      params: {
        start: params.page,
        limit: params.pageSize,
        search: params.searchQuery,
        startDate: params.startDate || 'All',
        endDate: params.endDate || 'All'
      }
    })

    if (result?.error) return thunkAPI.rejectWithValue(result.error)

    return result.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response?.data?.message || err.message)
  }
})

// Create a new coin trader
export const createCoinTrader = createAsyncThunk('coinTrader/createCoinTrader', async (traderData, thunkAPI) => {
  try {
    const result = await axios.post(
      `${baseURL}/api/admin/cointrader/registerCoinTrader`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          uniqueId: traderData.uniqueId,
          coin: traderData.coin,
          mobileNumber: traderData.mobileNumber,
          countryCode: traderData.countryCode
        }
      }
    )

    if (!result.data.status) {
      throw new Error(result.data.message || 'Failed to create coin trader')
    }

    toast.success(result.data.message || 'Coin trader created successfully')

    return result.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Update coin trader profile
export const updateCoinTrader = createAsyncThunk('coinTrader/updateCoinTrader', async (traderData, thunkAPI) => {
  try {
    const result = await axios.patch(
      `${baseURL}/api/admin/cointrader/updateCoinTraderProfile`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          coinTraderId: traderData.coinTraderId,
          mobileNumber: traderData.mobileNumber,
          countryCode: traderData.countryCode
        }
      }
    )

    if (!result.data.status) {
      throw new Error(result.data.message || 'Failed to update coin trader')
    }

    toast.success(result.data.message || 'Coin trader updated successfully')

    return result.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Update coins for trader
export const updateCoinForTrader = createAsyncThunk('coinTrader/updateCoinForTrader', async (coinData, thunkAPI) => {
  try {
    const result = await axios.patch(
      `${baseURL}/api/admin/cointrader/updateCoinForTraderByAdmin`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          coinTraderId: coinData.coinTraderId,
          coin: coinData.coin,
          type: coinData.type // 'add' or 'less'
        }
      }
    )

    if (!result.data.status) {
      throw new Error(result.data.message || 'Failed to update coins')
    }

    toast.success(result.data.message || 'Coins updated successfully')

    return result.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

// Toggle trader active status
export const toggleTraderStatus = createAsyncThunk('coinTrader/toggleStatus', async (traderData, thunkAPI) => {
  try {
    const result = await axios.patch(
      `${baseURL}/api/admin/cointrader/updateCoinTraderActiveStatus`,
      {},
      {
        headers: getAuthHeaders(),
        params: {
          coinTraderId: traderData.coinTraderId,
          userId: traderData.userId
        }
      }
    )

    if (!result.data.status) {
      throw new Error(result.data.message || 'Failed to update trader status')
    }

    toast.success(result.data.message || 'Trader status updated successfully')

    return result.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    toast.error(errorMessage)

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

export const fetchCoinTraderHistory = createAsyncThunk(
  'coinTrader/fetchCoinTraderHistory',
  async ({ traderId, start = 1, limit = 10 }, thunkAPI) => {
    try {
      // Get the current state
      const state = thunkAPI.getState().coinTrader

      // If traderId is not provided, return empty result
      if (!traderId) {
        return {
          status: true,
          message: 'No trader ID provided',
          totalCoin: 0,
          totalRecords: 0,
          history: []
        }
      }

      const result = await axios.get(`${baseURL}/api/admin/coinTraderHistory/getCoinTraderHistory`, {
        headers: getAuthHeaders(),
        params: {
          coinTraderId: traderId,
          start: start,
          limit: limit
        }
      })

      if (!result.data.status) {
        throw new Error(result.data.message || 'Failed to fetch coin trader history')
      }

      return result.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message

      toast.error(errorMessage)

      return thunkAPI.rejectWithValue(errorMessage)
    }
  }
)

// Fetch user list for dropdown selection
export const fetchUserList = createAsyncThunk('coinTrader/fetchUserList', async (_, thunkAPI) => {
  try {
    const result = await axios.get(`${baseURL}/api/admin/user/fetchUserList?type=real`, {
      headers: getAuthHeaders()
    })

    if (!result.data.status) {
      throw new Error(result.data.message || 'Failed to fetch users')
    }

    return result.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message

    return thunkAPI.rejectWithValue(errorMessage)
  }
})

const coinTraderSlice = createSlice({
  name: 'coinTrader',
  initialState: {
    initialLoad: true,
    traders: [],
    history: [],
    historyPage: 1,
    historyLimit: 10,
    historyTotal: 0,
    historyLoading: false,
    historyInitialLoading: true,
    historyHasMore: true,
    totalCoin: 0,
    total: 0,
    page: 1,
    pageSize: 10,
    searchQuery: '',
    startDate: 'All',
    endDate: 'All',
    status: 'idle',
    error: null,
    users: [],
    usersLoading: false
  },
  reducers: {
    setSearchQuery: (state, action) => {
      state.searchQuery = action.payload
    },
    setPage: (state, action) => {
      state.page = action.payload
    },
    setPageSize: (state, action) => {
      state.pageSize = action.payload
    },
    setDateRange: (state, action) => {
      state.startDate = action.payload.startDate
      state.endDate = action.payload.endDate
    },
    resetHistoryPagination: state => {
      state.historyPage = 1
      state.historyInitialLoading = true
      state.historyLoading = false
      state.historyTotal = 0
      state.historyHasMore = true
      state.totalCoin = 0
    }
  },
  extraReducers: builder => {
    // Fetch all coin traders
    builder
      .addCase(fetchCoinTraders.pending, state => {
        state.status = 'loading'
        state.initialLoad = true
      })
      .addCase(fetchCoinTraders.fulfilled, (state, action) => {
        if (action.payload.status) {
          state.status = 'succeeded'
          state.initialLoad = false
          state.traders = action.payload.data || []
          state.total = action.payload.total || 0
        } else {
          state.status = 'failed'
          state.initialLoad = false
          state.error = action.payload.message
          toast.error(action.payload.message)
        }
      })
      .addCase(fetchCoinTraders.rejected, (state, action) => {
        state.status = 'failed'
        state.initialLoad = false
        state.error = action.payload
        toast.error(action.payload)
      })

    // Create coin trader
    builder
      .addCase(createCoinTrader.pending, state => {
        state.status = 'loading'
      })
      .addCase(createCoinTrader.fulfilled, (state, action) => {
        state.status = 'succeeded'

        // Format the response data to match the GET API structure
        if (action.payload.status && action.payload.data) {
          const { data } = action.payload

          // Create a properly formatted trader object from the response
          const newTrader = {
            _id: data._id || '',
            uniqueId: data.uniqueId,
            countryCode: data.countryCode,
            mobileNumber: data.mobileNumber,
            coin: data.coin,
            spendCoin: 0,
            isActive: true,
            createdAt: new Date().toISOString(),
            userDetails: {
              name: data.userId?.name || '',
              userName: data.userId?.userName || '',
              image: data.userId?.image || ''
            }
          }

          // Add to the beginning of the list
          state.traders = [newTrader, ...state.traders]
          state.total += 1
        }
      })
      .addCase(createCoinTrader.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.payload
      })

    // Update coin trader
    builder
      .addCase(updateCoinTrader.pending, state => {
        state.status = 'loading'
      })
      .addCase(updateCoinTrader.fulfilled, (state, action) => {
        state.status = 'succeeded'

        if (action.payload.status && action.payload.data) {
          const updatedTrader = action.payload.data

          state.traders = state.traders.map(trader => {
            if (trader._id === updatedTrader._id) {
              return {
                ...trader,
                countryCode: updatedTrader.countryCode,
                mobileNumber: updatedTrader.mobileNumber
              }
            }

            return trader
          })
        }
      })
      .addCase(updateCoinTrader.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.payload
      })

    // Update coins for trader
    builder
      .addCase(updateCoinForTrader.pending, state => {
        state.status = 'loading'
      })
      .addCase(updateCoinForTrader.fulfilled, (state, action) => {
        state.status = 'succeeded'

        if (action.payload.status && action.payload.data) {
          const updatedTrader = action.payload.data

          state.traders = state.traders.map(trader => {
            if (trader._id === updatedTrader._id || trader._id === updatedTrader.coinTraderId) {
              return {
                ...trader,
                coin: updatedTrader.coin
              }
            }

            return trader
          })
        }
      })
      .addCase(updateCoinForTrader.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.payload
      })

    // Toggle trader status
    builder
      .addCase(toggleTraderStatus.pending, state => {
        state.status = 'loading'
      })
      .addCase(toggleTraderStatus.fulfilled, (state, action) => {
        state.status = 'succeeded'

        if (action.payload.status && action.payload.coinTrader) {
          const updatedTrader = action.payload.coinTrader

          state.traders = state.traders.map(trader => {
            if (trader._id === updatedTrader._id || trader._id === updatedTrader.coinTraderId) {
              return {
                ...trader,
                isActive: updatedTrader.isActive
              }
            }

            return trader
          })
        }
      })
      .addCase(toggleTraderStatus.rejected, (state, action) => {
        state.status = 'failed'
        state.error = action.payload
      })

    // Fetch coin trader history
    builder
      .addCase(fetchCoinTraderHistory.pending, (state, action) => {
        // Only set initial loading on first fetch
        if (state.historyPage === 1) {
          state.historyInitialLoading = true
        }

        state.historyLoading = true
      })
      .addCase(fetchCoinTraderHistory.fulfilled, (state, action) => {
        state.historyLoading = false
        state.historyInitialLoading = false

        if (action.payload.status) {
          const newHistory = action.payload.history || []

          // If this is the first page, replace the array, otherwise append
          if (state.historyPage === 1) {
            state.history = newHistory
          } else {
            // Filter out duplicates before adding
            const existingIds = new Set(state.history.map(item => item._id))
            const uniqueNewItems = newHistory.filter(item => !existingIds.has(item._id))

            state.history = [...state.history, ...uniqueNewItems]
          }

          state.historyTotal = action.payload.totalRecords || 0
          state.totalCoin = action.payload.totalCoin || 0

          // Determine if there are more items to fetch
          state.historyHasMore = state.history.length < state.historyTotal

          // Increment the page for next fetch if we received results
          if (newHistory.length > 0) {
            state.historyPage += 1
          }
        }
      })
      .addCase(fetchCoinTraderHistory.rejected, (state, action) => {
        state.historyLoading = false
        state.historyInitialLoading = false
        state.error = action.payload
      })

    // Fetch user list
    builder
      .addCase(fetchUserList.pending, state => {
        state.usersLoading = true
      })
      .addCase(fetchUserList.fulfilled, (state, action) => {
        state.usersLoading = false

        if (action.payload.status) {
          state.users = action.payload.data || []
        }
      })
      .addCase(fetchUserList.rejected, (state, action) => {
        state.usersLoading = false
        state.error = action.payload
      })
  }
})

export const { setSearchQuery, setPage, setPageSize, setDateRange, resetHistoryPagination } = coinTraderSlice.actions

export default coinTraderSlice.reducer
