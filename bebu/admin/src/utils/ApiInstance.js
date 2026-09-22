import axios from 'axios'

// import { setToast } from "./toastServices";

import { createSelector } from 'reselect'

import { secretKey, baseURL } from '@/config'

const selectStates = state => state

export const isLoading = createSelector(selectStates, state => {
  const slices = Object.values(state)

  const loading = slices.some(slice => {
    if (typeof slice === 'object' && slice !== null && slice.isLoading === true) {
      return true
    }

    return false
  })

  return loading
})

const getTokenData = () => {
  if (typeof localStorage !== 'undefined') {
    return localStorage.getItem('admin_token')
  }

  return null
}

const getUID = () => {
  if (typeof localStorage !== 'undefined') {
    return localStorage.getItem('uid')
  }

  return null
}

export const apiInstance = axios.create({
  baseURL: baseURL,
  headers: {
    key: secretKey,
    'Content-Type': 'application/json'
  }
})

// eslint-disable-next-line import/no-named-as-default-member
const cancelTokenSource = axios.CancelToken.source()
const token = getTokenData()

axios.defaults.headers.common['Authorization'] = token ? `${token}` : ''
axios.defaults.headers.common['key'] = secretKey

apiInstance.interceptors.request.use(
  config => {
    config.cancelToken = cancelTokenSource.token

    return config
  },
  error => {
    return Promise.reject(error)
  }
)

apiInstance.interceptors.response.use(
  response => response.data,
  async error => {
    const errorData = error.response?.data
    const status = error.response?.status

    // Handle 401 Unauthorized errors (token expired)
    if (status === 401) {
      // Check if error indicates token expiration
      const isExpired =
        errorData?.error?.includes('expired') ||
        errorData?.message?.includes('expired') ||
        errorData?.msg?.includes('expired')

      if (isExpired) {
        try {
          // Import here to avoid circular dependencies
          const { refreshFirebaseToken, isRememberMeEnabled } = await import('./firebase-auth')
          const { handleLogout } = await import('./auth-interceptor')

          // If remember me is enabled, try to refresh the token
          if (isRememberMeEnabled()) {
            // Refresh the token
            const newToken = await refreshFirebaseToken()

            // Update the axios headers with the new token
            axios.defaults.headers.common['Authorization'] = newToken
            error.config.headers['Authorization'] = newToken

            // Retry the original request with new token
            return apiInstance(error.config)
          } else {
            // If remember me is not enabled, log the user out
            await handleLogout()

            return Promise.reject(error)
          }
        } catch (refreshError) {
          console.error('Token refresh failed:', refreshError)

          // If token refresh fails, log the user out
          const { handleLogout } = await import('./auth-interceptor')

          await handleLogout()

          return Promise.reject(error)
        }
      }
    }

    // Check for 500 or 403 status codes
    if (status === 500 || status === 403) {
      sessionStorage.clear()
      localStorage.clear()
      axios.defaults.headers.common['key'] = ''
      axios.defaults.headers.common['Authorization'] = ''
      window.location.href = '/'
    }

    if (!errorData) {
      return Promise.reject(error)
    }

    if (errorData.code === 'E_USER_NOT_FOUND' || errorData.code === 'E_UNAUTHORIZED') {
      localStorage.clear()
      window.location.reload()
    }

    return Promise.reject(error)
  }
)

const handleErrors = async response => {
  if (!response.ok) {
    const data = await response.json().catch(() => ({}))

    // Handle 401 Unauthorized errors (token expired)
    if (response.status === 401) {
      // Check if error indicates token expiration
      const isExpired =
        data?.error?.includes('expired') || data?.message?.includes('expired') || data?.msg?.includes('expired')

      if (isExpired) {
        try {
          // Import here to avoid circular dependencies
          const { refreshFirebaseToken, isRememberMeEnabled } = await import('./firebase-auth')
          const { handleLogout } = await import('./auth-interceptor')

          // If remember me is enabled, try to refresh the token
          if (isRememberMeEnabled()) {
            // Refresh the token
            await refreshFirebaseToken()

            // The calling function should retry with the new token
            return { retryNeeded: true }
          } else {
            // If remember me is not enabled, log the user out
            await handleLogout()

            return Promise.reject(data)
          }
        } catch (refreshError) {
          console.error('Token refresh failed:', refreshError)

          // If token refresh fails, log the user out
          const { handleLogout } = await import('./auth-interceptor')

          await handleLogout()

          return Promise.reject(data)
        }
      }
    }

    // Check for 500 or 403 status codes
    if (response.status === 500 || response.status === 403) {
      sessionStorage.clear()
      localStorage.clear()
      window.location.href = '/'

      return Promise.reject(data)
    }

    if (Array.isArray(data.message)) {
      data.message.forEach(msg => setToast('error', msg))
    } else {
      setToast('error', data.message || 'Unexpected error occurred.')
    }

    return Promise.reject(data)
  }

  return response.json()
}

const getHeaders = () => ({
  key: secretKey,
  Authorization: getTokenData() ? `Bearer ${getTokenData()}` : '',
  'Content-Type': 'application/json',
  'x-auth-adm': getUID()
})

export const apiInstanceFetch = {
  baseURL: baseURL,

  get: async url => {
    const makeRequest = async () => {
      const result = await fetch(`${baseURL}${url}`, {
        method: 'GET',
        headers: getHeaders()
      }).then(handleErrors)

      return result
    }

    try {
      return await makeRequest()
    } catch (error) {
      // If token refresh happened and we need to retry
      if (error?.retryNeeded) {
        return await makeRequest()
      }

      throw error
    }
  },

  post: async (url, data) => {
    const makeRequest = async () => {
      const result = await fetch(`${baseURL}${url}`, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(data)
      }).then(handleErrors)

      return result
    }

    try {
      return await makeRequest()
    } catch (error) {
      // If token refresh happened and we need to retry
      if (error?.retryNeeded) {
        return await makeRequest()
      }

      throw error
    }
  },

  patch: async (url, data) => {
    const makeRequest = async () => {
      const result = await fetch(`${baseURL}${url}`, {
        method: 'PATCH',
        headers: getHeaders(),
        body: JSON.stringify(data)
      }).then(handleErrors)

      return result
    }

    try {
      return await makeRequest()
    } catch (error) {
      // If token refresh happened and we need to retry
      if (error?.retryNeeded) {
        return await makeRequest()
      }

      throw error
    }
  },

  put: async (url, data) => {
    const makeRequest = async () => {
      const result = await fetch(`${baseURL}${url}`, {
        method: 'PUT',
        headers: getHeaders(),
        body: JSON.stringify(data)
      }).then(handleErrors)

      return result
    }

    try {
      return await makeRequest()
    } catch (error) {
      // If token refresh happened and we need to retry
      if (error?.retryNeeded) {
        return await makeRequest()
      }

      throw error
    }
  },

  delete: async url => {
    const makeRequest = async () => {
      const result = await fetch(`${baseURL}${url}`, {
        method: 'DELETE',
        headers: getHeaders()
      }).then(handleErrors)

      return result
    }

    try {
      return await makeRequest()
    } catch (error) {
      // If token refresh happened and we need to retry
      if (error?.retryNeeded) {
        return await makeRequest()
      }

      throw error
    }
  }
}
