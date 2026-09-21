'use client'

import { useEffect, useState } from 'react'

import { useRouter } from 'next/navigation'

import { onAuthStateChanged } from 'firebase/auth'

import { auth } from '@/libs/firebase'
import { initTokenRefresh } from '@/utils/token-refresh-middleware'
import { isRememberMeEnabled } from '@/utils/firebase-auth'

const ProtectedLayout = ({ children }) => {
  const router = useRouter()
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, user => {
      if (user) {
        // User is authenticated
        setIsAuthenticated(true)

        // Initialize token refresh if remember me is enabled
        if (isRememberMeEnabled()) {
          initTokenRefresh()
        }
      } else {
        // User is not authenticated, redirect to login
        router.replace('/login')
      }

      setIsLoading(false)
    })

    return () => unsubscribe() // Cleanup subscription
  }, [router])

  if (isLoading) {
    // Show loading state
    return (
      <div className='flex justify-center items-center min-h-screen'>
        <p>Loading...</p>
      </div>
    )
  }

  if (!isAuthenticated) {
    // Don't render anything while redirecting
    return null
  }

  // User is authenticated, render the protected content
  return children
}

export default ProtectedLayout
