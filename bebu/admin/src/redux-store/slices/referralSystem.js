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

// Fetch all referral systems
export const fetchReferralSystems = createAsyncThunk('referralSystem/fetchAll', async (_, thunkAPI) => {
  try {
    const response = await axios.get(`${BASE_URL}/api/admin/referralSystem/retrieveReferralSystems`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Create new referral system
export const createReferralSystem = createAsyncThunk(
  'referralSystem/create',
  async ({ targetReferrals, rewardCoins }, thunkAPI) => {
    try {
      const response = await axios.post(
        `${BASE_URL}/api/admin/referralSystem/addReferralSystem?targetReferrals=${targetReferrals}&rewardCoins=${rewardCoins}`,
        {},
        { headers: getAuthHeaders() }
      )

      toast.success(response.data.message || 'Referral system created successfully')

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Update referral system
export const updateReferralSystem = createAsyncThunk(
  'referralSystem/update',
  async ({ targetReferrals, rewardCoins, referralId }, thunkAPI) => {
    try {
      const response = await axios.patch(
        `${BASE_URL}/api/admin/referralSystem/modifyReferralSystem?targetReferrals=${targetReferrals}&rewardCoins=${rewardCoins}&referralId=${referralId}`,
        {},
        { headers: getAuthHeaders() }
      )

      toast.success(response.data.message || 'Referral system updated successfully')

      return response.data
    } catch (error) {
      const errorMsg = error.response?.data?.message || error.message

      toast.error(errorMsg)

      return thunkAPI.rejectWithValue(errorMsg)
    }
  }
)

// Toggle referral system state
export const toggleReferralSystem = createAsyncThunk('referralSystem/toggle', async (referralId, thunkAPI) => {
  try {
    const response = await axios.patch(
      `${BASE_URL}/api/admin/referralSystem/updateReferralSystemState?referralId=${referralId}`,
      {},
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Referral system status updated successfully')

    return response.data
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

// Delete referral system
export const deleteReferralSystem = createAsyncThunk('referralSystem/delete', async (referralId, thunkAPI) => {
  try {
    const response = await axios.delete(
      `${BASE_URL}/api/admin/referralSystem/removeReferralSystem?referralId=${referralId}`,
      { headers: getAuthHeaders() }
    )

    toast.success(response.data.message || 'Referral system deleted successfully')

    return { referralId, ...response.data }
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message

    toast.error(errorMsg)

    return thunkAPI.rejectWithValue(errorMsg)
  }
})

const initialState = {
  referralSystems: [],
  initialLoading: true,
  loading: false,
  error: null
}

const referralSystemSlice = createSlice({
  name: 'referralSystem',
  initialState,
  reducers: {},
  extraReducers: builder => {
    builder

      // Fetch referral systems
      .addCase(fetchReferralSystems.pending, state => {
        state.initialLoading = true
        state.error = null
      })
      .addCase(fetchReferralSystems.fulfilled, (state, action) => {
        state.initialLoading = false

        if (action.payload.status) {
          state.referralSystems = action.payload.data
        }
      })
      .addCase(fetchReferralSystems.rejected, (state, action) => {
        state.initialLoading = false
        state.error = action.payload
      })

      // Create referral system

      .addCase(createReferralSystem.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.referralSystems.push(action.payload.data)
        }
      })
      .addCase(createReferralSystem.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Update referral system
      .addCase(updateReferralSystem.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          const updatedSystem = action.payload.data

          state.referralSystems = state.referralSystems.map(system =>
            system._id === updatedSystem._id ? updatedSystem : system
          )
        }
      })
      .addCase(updateReferralSystem.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Toggle referral system
      .addCase(toggleReferralSystem.fulfilled, (state, action) => {
        if (action.payload.status) {
          const updatedSystem = action.payload.data

          state.referralSystems = state.referralSystems.map(system =>
            system._id === updatedSystem._id ? updatedSystem : system
          )
        }
      })
      .addCase(toggleReferralSystem.rejected, (state, action) => {
        state.error = action.payload
      })

      // Delete referral system
      .addCase(deleteReferralSystem.pending, state => {
        state.loading = true
      })
      .addCase(deleteReferralSystem.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          state.referralSystems = state.referralSystems.filter(system => system._id !== action.payload.referralId)
        }
      })
      .addCase(deleteReferralSystem.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })
  }
})

export default referralSystemSlice.reducer
