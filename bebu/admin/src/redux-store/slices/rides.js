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

export const fetchRides = createAsyncThunk('api/admin/ride/fetchRides', async () => {
  const response = await axios.get(`${BASE_URL}/api/admin/ride/fetchRides`, {
    headers: getAuthHeaders()
  })

  // console.log(response)

  return response.data.data
})

export const toggleRideStatus = createAsyncThunk('api/admin/ride/toggleRideStatus', async rideId => {
  const response = await axios.patch(
    `${BASE_URL}/api/admin/ride/toggleRideStatus?rideId=${rideId}`,
    {},
    {
      headers: getAuthHeaders()
    }
  )

  return response.data
})

export const toggleRideRecommendation = createAsyncThunk('api/admin/ride/toggleRideRecommendation', async rideId => {
  const response = await axios.patch(
    `${BASE_URL}/api/admin/ride/toggleRideRecommendation?rideId=${rideId}`,
    {},
    {
      headers: getAuthHeaders()
    }
  )

  return response.data
})

export const createRide = createAsyncThunk('api/admin/ride/addRide', async (body, { rejectWithValue }) => {
  try {
    const response = await axios.post(`${BASE_URL}/api/admin/ride/addRide`, body, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (error) {
    return rejectWithValue(error.response.data.message)
  }
})

export const editRide = createAsyncThunk('rides/editRide', async ({ body, query }, thunkAPI) => {
  try {
    const response = await axios.patch(`${BASE_URL}/api/admin/ride/modifyRide?rideId=${query}`, body, {
      headers: {
        ...getAuthHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    })

    return response.data
  } catch (err) {
    return thunkAPI.rejectWithValue(err.response.data)
  }
})

export const deleteRide = createAsyncThunk('api/admin/ride/removeRide', async (rideId, { rejectWithValue }) => {
  try {
    const response = await axios.delete(`${BASE_URL}/api/admin/ride/removeRide?rideId=${rideId}`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (error) {
    return rejectWithValue(error.response.data.message)
  }
})

const ridesSlice = createSlice({
  name: 'rides',
  initialState: {
    rides: [],
    initialLoading: true,
    loading: false,
    error: null
  },
  reducers: {},
  extraReducers: builder => {
    builder
      .addCase(fetchRides.pending, state => {
        state.loading = true
        state.error = null
      })

      .addCase(fetchRides.fulfilled, (state, action) => {
        state.loading = false
        state.initialLoading = false
        state.rides = action.payload
      })

      .addCase(fetchRides.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      //_________________________________________________________toggleRideStatus____________________________________________________________
      .addCase(toggleRideStatus.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)

          const ride = state.rides.find(r => r._id === action.meta.arg)

          if (ride) {
            ride.isActive = !ride.isActive
          }
        } else {
          toast.error(action.payload.message)
        }
      })

      .addCase(toggleRideRecommendation.fulfilled, (state, action) => {
        if (action.payload.status) {
          toast.success(action.payload.message)
          const ride = state.rides.find(r => r._id === action.meta.arg)

          if (ride) {
            ride.isRecommended = !ride.isRecommended
          }
        } else {
          toast.error(action.payload.message)
        }
      })

      //_________________________________________________________createRide____________________________________________________________
      .addCase(createRide.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.rides.unshift(action.payload.data)
        } else {
          toast.error(action.payload.message)
        }
      })

      .addCase(createRide.rejected, (state, action) => {
        state.loading = false
        toast.error(action.payload.message)
      })

      //_________________________________________________________editRide____________________________________________________________
      .addCase(editRide.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.rides = state.rides.map(ride => {
            if (ride._id === action.meta.arg.query) {
              return action.payload.data
            }

            return ride
          })
        } else {
          toast.error(action.payload.message)
        }
      })

      .addCase(editRide.rejected, (state, action) => {
        state.loading = false
        toast.error(action.payload.message)
      })

      //_________________________________________________________deleteRide____________________________________________________________
      .addCase(deleteRide.fulfilled, (state, action) => {
        state.loading = false

        if (action.payload.status) {
          toast.success(action.payload.message)
          state.rides = state.rides.filter(r => r._id !== action.meta.arg)
        } else {
          toast.error(action.payload.message)
        }
      })

      .addCase(deleteRide.rejected, (state, action) => {
        state.loading = false
        toast.error(action.payload.message)
      })
  }
})

export default ridesSlice.reducer
