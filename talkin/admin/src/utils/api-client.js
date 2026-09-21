import { handleAuthResponse } from './auth-interceptor'

/**
 * Base API client with authentication handling
 */
export const apiClient = {
  /**
   * Make a fetch request with authentication handling
   * @param {string} url - API endpoint
   * @param {Object} options - Fetch options
   * @returns {Promise<any>} Response data
   */
  fetch: async (url, options = {}) => {
    const fetchWithAuth = async () => {
      // Get the latest token
      const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : null

      // Set authorization header if token exists
      const headers = {
        'Content-Type': 'application/json',
        ...options.headers
      }

      if (token) {
        headers.Authorization = `Bearer ${token}`
      }

      // Make the request
      const response = await fetch(url, {
        ...options,
        headers
      })

      // Handle auth issues with response
      return handleAuthResponse(response, () => fetchWithAuth())
    }

    return fetchWithAuth()
  },

  /**
   * Make a GET request
   * @param {string} url - API endpoint
   * @param {Object} options - Additional options
   * @returns {Promise<any>} Response data
   */
  get: (url, options = {}) => {
    return apiClient.fetch(url, {
      ...options,
      method: 'GET'
    })
  },

  /**
   * Make a POST request
   * @param {string} url - API endpoint
   * @param {Object} data - Request payload
   * @param {Object} options - Additional options
   * @returns {Promise<any>} Response data
   */
  post: (url, data, options = {}) => {
    return apiClient.fetch(url, {
      ...options,
      method: 'POST',
      body: JSON.stringify(data)
    })
  },

  /**
   * Make a PUT request
   * @param {string} url - API endpoint
   * @param {Object} data - Request payload
   * @param {Object} options - Additional options
   * @returns {Promise<any>} Response data
   */
  put: (url, data, options = {}) => {
    return apiClient.fetch(url, {
      ...options,
      method: 'PUT',
      body: JSON.stringify(data)
    })
  },

  /**
   * Make a DELETE request
   * @param {string} url - API endpoint
   * @param {Object} options - Additional options
   * @returns {Promise<any>} Response data
   */
  delete: (url, options = {}) => {
    return apiClient.fetch(url, {
      ...options,
      method: 'DELETE'
    })
  }
}
