import { setPersistence, browserLocalPersistence, browserSessionPersistence } from 'firebase/auth'

import { auth } from '@/libs/firebase'

/**
 * Refreshes the Firebase token
 * @returns {Promise<string>} The new token
 */
export const refreshFirebaseToken = async () => {
  const currentUser = auth.currentUser

  if (!currentUser) {
    throw new Error('No user is signed in')
  }

  // Force refresh the token
  const newToken = await currentUser.getIdToken(true)

  // Store the new token
  if (typeof window !== 'undefined') {
    localStorage.setItem('admin_token', newToken)
  }

  return newToken
}

/**
 * Get current Firebase token expiration time
 * @returns {Promise<number>} Timestamp in milliseconds when token will expire
 */
export const getTokenExpirationTime = async () => {
  const currentUser = auth.currentUser

  if (!currentUser) {
    throw new Error('No user is signed in')
  }

  const tokenResult = await currentUser.getIdTokenResult()

  return new Date(tokenResult.expirationTime).getTime()
}

/**
 * Set user remember me preference
 * @param {boolean} remember Whether to remember the user
 */
// export const setRememberMe = remember => {
//   if (typeof window !== 'undefined') {
//     localStorage.setItem('remember_me', remember ? 'true' : 'false')
//   }
// }

/**
 * Check if user has selected "Remember Me"
 * @returns {boolean} Whether user should be remembered
 */
export const isRememberMeEnabled = () => {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('remember_me') === 'true'
  }

  return false
}

/**
 * Sets the persistence mode for Firebase authentication based on 'remember me' preference
 * @param {boolean} remember - Whether to persist the auth state
 * @returns {Promise<void>}
 */
export const setRememberMe = async remember => {
  try {
    const persistenceType = remember ? browserLocalPersistence : browserSessionPersistence

    await setPersistence(auth, persistenceType)

    return true
  } catch (error) {
    console.error('Auth persistence error:', error)

    return false
  }
}

/**
 * Validates if the current authentication is valid
 * - Checks if token exists in localStorage
 * - Checks if uid exists in localStorage
 * - Verifies if the current Firebase user matches
 *
 * @returns {Promise<boolean>} True if authentication is valid
 */
export const validateAuthentication = async () => {
  try {
    // Check if there's a user in Firebase
    const currentUser = auth.currentUser

    if (!currentUser) return false

    // Check if we have the required localStorage items
    const storedUid = localStorage.getItem('uid')
    const storedToken = localStorage.getItem('admin_token')

    if (!storedUid || !storedToken) return false

    // Check if the Firebase user matches the stored uid
    if (currentUser.uid !== storedUid) return false

    // Get a fresh token from Firebase and compare
    const freshToken = await currentUser.getIdToken(true)

    // Optional: Add additional validation like token expiration check

    return true
  } catch (error) {
    console.error('Authentication validation error:', error)

    return false
  }
}

/**
 * Clean up authentication state
 * - Clears localStorage items
 * - Signs out from Firebase
 *
 * @returns {Promise<void>}
 */
export const cleanupAuthentication = async () => {
  try {
    // Clear localStorage
    localStorage.removeItem('uid')
    localStorage.removeItem('admin_token')
    localStorage.removeItem('user')
    sessionStorage.removeItem('manual_login_in_progress')

    // Sign out from Firebase
    if (auth.currentUser) {
      await auth.signOut()
    }
  } catch (error) {
    console.error('Auth cleanup error:', error)
  }
}

/**
 * Handles Firebase authentication errors
 * @param {Object} error - Firebase auth error object
 * @returns {string} Human-readable error message
 */
export const handleFirebaseAuthError = error => {
  const errorCode = error?.code

  const errorMessages = {
    'auth/user-not-found': 'User does not exist.',
    'auth/wrong-password': 'Invalid password.',
    'auth/invalid-email': 'Invalid email address.',
    'auth/too-many-requests': 'Too many login attempts. Please try again later.',
    'auth/network-request-failed': 'Network error. Please check your connection.',
    'auth/invalid-credential': 'Invalid credentials. Please check your email and password.',
    'auth/account-exists-with-different-credential':
      'An account already exists with the same email address but different sign-in credentials.',
    'auth/user-disabled': 'This user account has been disabled.',
    'auth/operation-not-allowed': 'This operation is not allowed.',
    'auth/popup-closed-by-user': 'Login popup was closed before completing the sign-in process.',
    'auth/cancelled-popup-request': 'This operation has been cancelled due to another conflicting popup being opened.',
    'auth/popup-blocked': 'The popup was blocked by the browser.',
    'auth/unauthorized-domain': 'This domain is not authorized for OAuth operations.'
  }

  return errorMessages[errorCode] || 'Login failed. Please check your credentials.'
}

/**
 * Get authentication headers for API requests
 * @returns {Object} Authentication headers for API requests
 */
export const getAuthHeaders = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    if (token && uid) {
      return {
        Authorization: `Bearer ${token}`,
        'x-admin-uid': uid
      }
    }
  }

  return {}
}
