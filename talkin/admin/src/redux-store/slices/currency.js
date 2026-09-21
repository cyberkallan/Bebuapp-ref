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

// Fetch all currencies
export const fetchCurrencies = createAsyncThunk('currency/fetchCurrency', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/currency/fetchCurrency`, {
      headers: getAuthHeaders()
    })

    return response.data.data || []
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

export const fetchDefaultCurrencies = createAsyncThunk('currency/fetchDefaultCurrency', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/currency/fetchDefaultCurrency`, {
      headers: getAuthHeaders()
    })

    return response.data.data || null
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Create new currency
export const createCurrency = createAsyncThunk(
  'currency/insertCurrency',
  async ({ name, symbol, countryCode, currencyCode }, thunkAPI) => {
    try {
      const response = await axios.post(
        `${BASE_URL}/api/admin/currency/insertCurrency`,
        { name, symbol, countryCode, currencyCode },
        { headers: getAuthHeaders() }
      )

      toast.success(response.data.message || 'Currency created successfully')

      return response.data.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Update currency
export const updateCurrency = createAsyncThunk(
  'currency/updateCurrency',
  async ({ currencyId, name, symbol, countryCode, currencyCode }, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/currency/updateCurrency`,
        { currencyId, name, symbol, countryCode, currencyCode },
        { headers: getAuthHeaders() }
      )

      toast.success(response.data.message || 'Currency updated successfully')

      return response.data.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Delete currency
export const deleteCurrency = createAsyncThunk('currency/disableCurrency', async (currencyId, thunkAPI) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/currency/disableCurrency?currencyId=${currencyId}`, {
      headers: getAuthHeaders()
    })

    toast.success(response.data.message || 'Currency deleted successfully')

    return { id: currencyId }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Set default currency
export const setDefaultCurrency = createAsyncThunk('currency/setDefaultCurrency', async (currencyId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/currency/setDefaultCurrency?currencyId=${currencyId}`,
      {},
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Default currency updated successfully')

    return response.data.data || []
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  currencies: [],
  defaultCurrency: null,
  initialLoading: true,
  loading: false,
  error: null
}

const currencySlice = createSlice({
  name: 'currency',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch currencies
      .addCase(fetchCurrencies.pending, state => {
        state.initialLoading = true
        state.error = null
      })
      .addCase(fetchCurrencies.fulfilled, (state, action) => {
        state.initialLoading = false
        state.currencies = action.payload
      })
      .addCase(fetchCurrencies.rejected, (state, action) => {
        state.initialLoading = false
        state.error = action.payload
      })

      // Create currency
      .addCase(createCurrency.pending, state => {
        state.loading = true
      })
      .addCase(createCurrency.fulfilled, (state, action) => {
        state.loading = false
        state.currencies.unshift(action.payload)
      })
      .addCase(createCurrency.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Update currency
      .addCase(updateCurrency.pending, state => {
        state.loading = true
      })
      .addCase(updateCurrency.fulfilled, (state, action) => {
        state.loading = false
        const index = state.currencies.findIndex(c => c._id === action.payload._id)

        if (index !== -1) {
          state.currencies[index] = action.payload
        }
      })
      .addCase(updateCurrency.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Delete currency
      .addCase(deleteCurrency.pending, state => {
        state.loading = true
      })
      .addCase(deleteCurrency.fulfilled, (state, action) => {
        state.loading = false
        state.currencies = state.currencies.filter(c => c._id !== action.payload.id)
      })
      .addCase(deleteCurrency.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Set default currency
      .addCase(setDefaultCurrency.pending, state => {
        state.loading = true
      })
      .addCase(setDefaultCurrency.fulfilled, (state, action) => {
        state.loading = false
        state.currencies = action.payload
        state.defaultCurrency = state.currencies.find(c => c.isDefault) || null
      })
      .addCase(setDefaultCurrency.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Get default currency
      .addCase(fetchDefaultCurrencies.pending, state => {
        // state.loading = true
      })
      .addCase(fetchDefaultCurrencies.fulfilled, (state, action) => {
        // state.loading = false
        state.defaultCurrency = action.payload
      })
      .addCase(fetchDefaultCurrencies.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
  }
})

export default currencySlice.reducer
