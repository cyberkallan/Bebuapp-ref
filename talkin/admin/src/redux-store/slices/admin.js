import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import axios from 'axios'

import { secretKey, baseURL } from '@/config'

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

export const loginAdmin = createAsyncThunk(
  'api/admin/authenticateAdmin',
  async ({ email, password }, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `${baseURL}/api/admin/authenticateAdmin`,
        { email, password },
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (err) {
      // Improved error handling
      const errorMessage = err.response?.data?.message || err.message || 'Login failed'

      return rejectWithValue(errorMessage)
    }
  }
)

export const signInAdmin = createAsyncThunk(
  '/api/admin/initiateAdminRegistration',
  async ({ email, password , uid , code , privateKey}, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `${baseURL}/api/admin/initiateAdminRegistration`,
        { email, password ,uid , code , privateKey},
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (err) {
      // Improved error handling
      const errorMessage = err.response?.data?.message || err.message || 'Registration failed'

      return rejectWithValue(errorMessage)
    }
  }
)


export const getDashboardData = createAsyncThunk(
  'api/admin/dashboard/dashboardMetrics',
  async (_, { rejectWithValue }) => {
    try {
      const response = await axios.get(`${baseURL}/api/admin/dashboard/dashboardMetrics`, {
        headers: getAuthHeaders()
      })

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Failed to fetch dashboard data'

      return rejectWithValue(errorMessage)
    }
  }
)

export const requestPasswordReset = createAsyncThunk(
  'api/admin/admin/requestPasswordReset',
  async ({ email }, { rejectWithValue }) => {
    try {
      const response = await axios.get(`${baseURL}/api/admin/admin/requestPasswordReset`, {
        params: { email },
        headers: getAuthHeaders()
      })

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Password reset request failed'

      return rejectWithValue(errorMessage)
    }
  }
)

export const resetPassword = createAsyncThunk(
  'api/admin/admin/resetPassword',
  async ({ newPassword, confirmPassword, token, uid }, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `${baseURL}/api/admin/admin/resetPassword`,
        { newPassword, confirmPassword },
        {
          headers: {
            'Content-Type': 'application/json',
            key: secretKey,
            Authorization: `Bearer ${token}`,
            'x-admin-uid': uid
          }
        }
      )

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Password reset failed'

      return rejectWithValue(errorMessage)
    }
  }
)

export const getAdminProfile = createAsyncThunk('api/admin/fetchAdminProfile', async (_, { rejectWithValue }) => {
  try {
    const response = await axios.get(`${baseURL}/api/admin/fetchAdminProfile`, {
      headers: getAuthHeaders()
    })

    return response.data
  } catch (err) {
    const errorMessage = err.response?.data?.message || err.message || 'Failed to fetch profile'

    return rejectWithValue(errorMessage)
  }
})

export const updateAdminProfile = createAsyncThunk(
  'api/admin/updateProfileDetails',
  async (formData, { rejectWithValue }) => {
    try {
      const response = await axios.patch(`${baseURL}/api/admin/updateProfileDetails`, formData, {
        headers: { ...getAuthHeaders(), 'Content-Type': 'multipart/form-data' }
      })

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Profile update failed'

      return rejectWithValue(errorMessage)
    }
  }
)

export const changePassword = createAsyncThunk(
  'api/admin/updatePassword',
  async ({ oldPass, newPass, confirmPass }, { rejectWithValue }) => {
    try {
      const response = await axios.patch(
        `${baseURL}/api/admin/updatePassword`,
        { oldPass, newPass, confirmPass },
        {
          headers: getAuthHeaders()
        }
      )

      return response.data
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'Password change failed'

      return rejectWithValue(errorMessage)
    }
  }
)

const adminSlice = createSlice({
  name: 'admin',
  initialState: {
    loading: false,
    user: null,
    error: null,
    resetStatus: null,
    profileData: null,
    passwordChangeStatus: null,
    profileUpdateStatus: null,
    loginStatus: 'idle' // Added to track login status
  },
  reducers: {
    clearResetStatus: state => {
      state.resetStatus = null
    },

    clearPasswordChangeStatus: state => {
      state.passwordChangeStatus = null
    },

    clearError: state => {
      state.error = null
    },

    logoutAdmin: state => {
      // Clear auth data from localStorage
      if (typeof window !== 'undefined') {
        localStorage.removeItem('uid')
        localStorage.removeItem('admin_token')
        localStorage.removeItem('user')
        sessionStorage.removeItem('manual_login_in_progress')
      }

      // Reset the state to initial values
      state.user = null
      state.error = null
      state.loading = false
      state.resetStatus = null
      state.profileData = null
      state.passwordChangeStatus = null
      state.profileUpdateStatus = null
      state.loginStatus = 'idle'
    },

    clearProfileUpdateStatus: state => {
      state.profileUpdateStatus = null
    }
  },
  extraReducers: builder => {
    builder

      // Login Admin
      .addCase(loginAdmin.pending, state => {
        state.loading = true
        state.error = null
        state.loginStatus = 'pending'
      })
      .addCase(loginAdmin.fulfilled, (state, action) => {
        state.loading = false
        state.user = action.payload
        state.loginStatus = 'success'

        // Store user data in localStorage
        if (typeof window !== 'undefined' && action.payload && action.payload.admin) {
          const user = {
            name: action.payload.admin.name,
            email: action.payload.admin.email,
            image: action.payload.admin.image
          }

          localStorage.setItem('user', JSON.stringify(user))
        }
      })
      .addCase(loginAdmin.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.loginStatus = 'failed'
      })

      // Login Admin
      .addCase(signInAdmin.pending, state => {
        state.loading = true
        state.error = null
        state.loginStatus = 'pending'
      })
      .addCase(signInAdmin.fulfilled, (state, action) => {
        state.loading = false
        state.user = action.payload
        
        // state.loginStatus = 'success'

        // // Store user data in localStorage
        // if (typeof window !== 'undefined' && action.payload && action.payload.admin) {
        //   const user = {
        //     name: action.payload.admin.name,
        //     email: action.payload.admin.email,
        //     image: action.payload.admin.image
        //   }

        //   localStorage.setItem('user', JSON.stringify(user))
        // }
      })
      .addCase(signInAdmin.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.loginStatus = 'failed'
      })

      // Dashboard Data
      .addCase(getDashboardData.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(getDashboardData.fulfilled, (state, action) => {
        state.loading = false
        state.dashboardData = action.payload
      })
      .addCase(getDashboardData.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Request Password Reset
      .addCase(requestPasswordReset.pending, state => {
        state.loading = true
        state.error = null
        state.resetStatus = 'pending'
      })
      .addCase(requestPasswordReset.fulfilled, state => {
        state.loading = false
        state.resetStatus = 'email_sent'
      })
      .addCase(requestPasswordReset.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.resetStatus = 'failed'
      })

      // Reset Password
      .addCase(resetPassword.pending, state => {
        state.loading = true
        state.error = null
        state.resetStatus = 'pending'
      })
      .addCase(resetPassword.fulfilled, state => {
        state.loading = false
        state.resetStatus = 'success'
      })
      .addCase(resetPassword.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.resetStatus = 'failed'
      })

      // Get Admin Profile
      .addCase(getAdminProfile.pending, state => {
        state.loading = true
        state.error = null
      })
      .addCase(getAdminProfile.fulfilled, (state, action) => {
        state.loading = false
        state.profileData = action.payload.data
      })
      .addCase(getAdminProfile.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
      })

      // Update Admin Profile
      .addCase(updateAdminProfile.pending, state => {
        state.loading = true
        state.error = null
        state.profileUpdateStatus = 'pending'
      })
      .addCase(updateAdminProfile.fulfilled, (state, action) => {
        state.loading = false
        state.profileData = { ...state.profileData, ...action.payload.data } || state.profileData
        state.profileUpdateStatus = 'success'
      })
      .addCase(updateAdminProfile.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.profileUpdateStatus = 'failed'
      })

      // Change Password
      .addCase(changePassword.pending, state => {
        state.loading = true
        state.error = null
        state.passwordChangeStatus = 'pending'
      })
      .addCase(changePassword.fulfilled, state => {
        state.loading = false
        state.passwordChangeStatus = 'success'
      })
      .addCase(changePassword.rejected, (state, action) => {
        state.loading = false
        state.error = action.payload
        state.passwordChangeStatus = 'failed'
      })
  }
})

export const { clearResetStatus, logoutAdmin, clearPasswordChangeStatus, clearProfileUpdateStatus, clearError } =
  adminSlice.actions

export default adminSlice.reducer
