import { refreshFirebaseToken, isRememberMeEnabled } from './firebase-auth'
import { auth } from '@/libs/firebase'

let refreshPromise = null

/**
 * Intercepts API responses and handles token refresh or logout
 * @param {Response} response - Fetch API response
 * @param {Function} retry - Function to retry the original request
 * @returns {Promise<any>} Response data or throws error
 */
export const handleAuthResponse = async (response, retry) => {
  // If response is successful, return it
  if (response.ok) return response

  // Handle unauthorized errors (401)
  if (response.status === 401) {
    // Check if the error is because of expired token
    const data = await response.json().catch(() => ({}))

    if (data.error?.includes('expired') || data.message?.includes('expired')) {
      // If user chose "Remember Me", try to refresh the token
      if (isRememberMeEnabled()) {
        try {
          // Use a single refresh promise to prevent multiple refresh attempts
          if (!refreshPromise) {
            refreshPromise = refreshFirebaseToken()
          }

          // Wait for token refresh
          await refreshPromise
          refreshPromise = null

          // Retry the original request with new token
          if (retry) {
            return retry()
          }
        } catch (error) {
          console.error('Failed to refresh token:', error)

          // If refresh fails, log the user out
          await handleLogout()
        }
      } else {
        // If "Remember Me" is not enabled, log the user out
        await handleLogout()
      }
    }
  }

  // If we couldn't handle the error, pass it through
  throw new Error(`API Error: ${response.status}`)
}

/**
 * Handle logout process
 */
export const handleLogout = async () => {
  try {
    // Sign out from Firebase
    await auth.signOut()

    // Clear localStorage
    if (typeof window !== 'undefined') {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('uid')
      localStorage.removeItem('remember_me')
    }

    // Redirect to login page
    // window.location.href = '/login'
    window.location.href = '/'
  } catch (error) {
    console.error('Logout error:', error)
  }
}
