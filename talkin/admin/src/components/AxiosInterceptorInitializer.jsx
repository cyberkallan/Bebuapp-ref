'use client'

import { useEffect } from 'react'

import setupAxiosInterceptors from '@/utils/setupAxiosInterceptors'

/**
 * Component to initialize axios interceptors on client-side
 */
const AxiosInterceptorInitializer = () => {
  useEffect(() => {
    // Initialize axios interceptors
    setupAxiosInterceptors()

    // Log initialization
    console.log('Axios interceptors initialized')
  }, [])

  // This component doesn't render anything
  return null
}

export default AxiosInterceptorInitializer
