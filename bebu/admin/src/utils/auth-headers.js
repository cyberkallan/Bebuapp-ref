import { secretKey, baseURL } from '@/config'

/**
 * Get authentication headers for API requests
 *
 * @param {Object} options - Optional configuration
 * @param {boolean} options.omitContentType - Whether to omit the Content-Type header
 * @returns {Object} Headers with authentication tokens
 */
export const getAuthHeaders = (options = {}) => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('admin_token')
    const uid = localStorage.getItem('uid')

    const headers = {
      key: secretKey,
      Authorization: token ? `Bearer ${token}` : '',
      'x-admin-uid': uid
    }

    // Only add Content-Type if not explicitly omitted
    // This allows the caller to set their own Content-Type (like multipart/form-data)
    if (!options.omitContentType) {
      headers['Content-Type'] = 'application/json'
    }

    return headers
  }

  return {}
}

/**
 * Configure axios instance with authentication headers
 *
 * @param {Object} axios - Axios instance
 * @param {Object} options - Optional configuration
 * @param {boolean} options.omitContentType - Whether to omit the Content-Type header
 * @param {boolean} options.respectContentType - Whether to respect existing Content-Type in config
 */
export const configureAxiosAuth = (axios, options = {}) => {
  // Set up request interceptor to always include the latest token
  axios.interceptors.request.use(
    config => {
      // Get fresh auth headers for each request
      const headers = getAuthHeaders({
        omitContentType: options.omitContentType || config.headers['Content-Type']?.includes('multipart/form-data')
      })

      // Add headers to the request
      Object.keys(headers).forEach(key => {
        // Skip setting Content-Type if it's already set and we should respect it
        if (key === 'Content-Type' && options.respectContentType && config.headers['Content-Type']) {
          return
        }

        // Skip Content-Type for FormData to let Axios handle it
        if (
          key === 'Content-Type' &&
          (config.data instanceof FormData || (typeof window !== 'undefined' && config.data instanceof window.FormData))
        ) {
          return
        }

        config.headers[key] = headers[key]
      })

      return config
    },
    error => Promise.reject(error)
  )
}
