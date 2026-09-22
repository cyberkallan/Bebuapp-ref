import axios from 'axios'

import { refreshFirebaseToken, isRememberMeEnabled } from './firebase-auth'
import { handleLogout } from './auth-interceptor'
import { configureAxiosAuth } from './auth-headers'

// Configure axios with authentication headers
// configureAxiosAuth(axios)

// Add a specific interceptor for FormData content type
axios.interceptors.request.use(
  config => {
    // Handle FormData correctly by not setting Content-Type
    if (config.data instanceof FormData || (typeof window !== 'undefined' && config.data instanceof window.FormData)) {
      // Remove Content-Type to let axios set it with boundary
      delete config.headers['Content-Type']
    }

    return config
  },
  error => Promise.reject(error)
)

// Setup response interceptor for 401 errors
axios.interceptors.response.use(
  response => response,
  async error => {
    // Extract error information
    const status = error.response?.status
    const data = error.response?.data || {}

    // For debugging
    console.log('API Error:', {
      status,
      message: data.message,
      error: data.error,
      url: error.config?.url
    })

    // Check if it's an unauthorized (401) error
    if (status === 401) {        
      // Check if error message indicates token expiration
      // Handle the specific error format from your API
      const isExpired =
        data.error?.includes?.('expired') ||
        data.message?.includes?.('expired') ||
        data.msg?.includes?.('expired') ||
        (typeof data.message === 'string' &&
          (data.message.includes('Invalid or expired token') || data.message.includes('Authorization failed')))

      if (isExpired) {
        console.log('Token expired, checking remember me status...')

        // Check if remember me is enabled
        if (isRememberMeEnabled()) {
          try {
            console.log('Remember Me is enabled, refreshing token...')

            // Refresh the token
            const newToken = await refreshFirebaseToken()

            // Update the authorization header for retry
            error.config.headers['Authorization'] = `Bearer ${newToken}`

            // Create a new instance to avoid interceptor loop
            return axios(error.config)
          } catch (refreshError) {
            console.error('Failed to refresh token:', refreshError)

            // If refresh fails, log the user out
            await handleLogout()

            return Promise.reject(error)
          }
        } else {
          console.log('Remember Me is NOT enabled, logging out...')

          // If remember me is not enabled, log the user out immediately
          await handleLogout()

          return Promise.reject(error)
        }
      }
    }

    // For other errors, just pass them through
    return Promise.reject(error)
  }
)

export default function setupAxiosInterceptors() {
  console.log('Axios global interceptors set up successfully')
}
