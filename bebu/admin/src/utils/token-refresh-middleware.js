import { useEffect } from 'react'

import { refreshFirebaseToken, getTokenExpirationTime, isRememberMeEnabled } from './firebase-auth'
import { handleLogout } from './auth-interceptor'

/**
 * Manages token refresh for the current session
 */
export class TokenRefreshManager {
  static instance = null
  refreshTimer = null

  /**
   * Get the singleton instance of TokenRefreshManager
   */
  static getInstance() {
    if (!TokenRefreshManager.instance) {
      TokenRefreshManager.instance = new TokenRefreshManager()
    }

    return TokenRefreshManager.instance
  }

  /**
   * Setup token refresh mechanism
   */
  setupTokenRefresh() {
    // Clear any existing timer
    this.clearRefreshTimer()

    // Only setup refresh if "Remember Me" is enabled
    if (!isRememberMeEnabled()) {
      console.log('Remember Me is not enabled, skipping token refresh setup')

      return
    }

    this.scheduleTokenRefresh()
  }

  /**
   * Schedule the next token refresh
   */
  async scheduleTokenRefresh() {
    try {
      // Get the current token expiration time
      const expirationTime = await getTokenExpirationTime()
      const now = Date.now()

      // Schedule refresh to happen 5 minutes before expiration
      const timeUntilRefresh = Math.max(0, expirationTime - now - 5 * 60 * 1000)

      console.log(`Token will be refreshed in ${Math.round(timeUntilRefresh / 1000)} seconds`)

      // Schedule the refresh
      this.refreshTimer = setTimeout(async () => {
        try {
          await refreshFirebaseToken()
          console.log('Token refreshed successfully')

          // Schedule the next refresh
          this.scheduleTokenRefresh()
        } catch (error) {
          console.error('Failed to refresh token:', error)

          // If token refresh fails, log the user out if remember me is disabled
          if (!isRememberMeEnabled()) {
            await handleLogout()
          }
        }
      }, timeUntilRefresh)
    } catch (error) {
      console.error('Error scheduling token refresh:', error)

      // If there's an error getting the expiration time,
      // likely the user is not logged in or the token is invalid
      if (!isRememberMeEnabled()) {
        await handleLogout()
      }
    }
  }

  /**
   * Clear the refresh timer
   */
  clearRefreshTimer() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
      this.refreshTimer = null
    }
  }

  /**
   * Clean up resources
   */
  cleanup() {
    this.clearRefreshTimer()
  }
}

/**
 * Initialize token refresh for the current session
 */
export const initTokenRefresh = () => {
  // Make sure we only run this on client-side
  if (typeof window !== 'undefined') {
    const manager = TokenRefreshManager.getInstance()

    manager.setupTokenRefresh()

    // Clean up when the window is unloaded
    window.addEventListener('beforeunload', () => {
      manager.cleanup()
    })
  }
}

/**
 * Higher-order component to protect routes and handle token refresh
 * @param {React.Component} Component - The component to protect
 * @returns {React.Component} Protected component
 */
export const withTokenRefresh = Component => {
  return function ProtectedRoute(props) {
    // Initialize token refresh when the component mounts
    useEffect(() => {
      initTokenRefresh()
    }, [])

    return <Component {...props} />
  }
}
