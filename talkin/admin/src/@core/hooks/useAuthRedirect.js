// hooks/useAuthRedirect.js
import { useEffect, useState } from 'react'

import { useRouter } from 'next/navigation'

import { onAuthStateChanged } from 'firebase/auth'

import { auth } from '@/libs/firebase'

export const useAuthRedirect = () => {
  const router = useRouter()
  const [checking, setChecking] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, user => {
      const isAuthPath =
        window.location.pathname === '/login' ||
        window.location.pathname === '/register' ||
        window.location.pathname === '/forgot-password' ||
        window.location.pathname.startsWith('/reset-password')

      if (user) {
        // User is authenticated
        if (isAuthPath) {
          // Redirect to dashboard if trying to access auth pages while logged in
          router.replace('/dashboard')
        }
      } else {
        // User is not authenticated
        if (!isAuthPath) {
          // Redirect to login if trying to access protected pages
          router.replace('/login')
        }
      }

      setChecking(false)
    })

    return () => unsubscribe()
  }, [router])

  return { checking }
}
