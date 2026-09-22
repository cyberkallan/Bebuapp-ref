'use client'

import { useEffect, useState } from 'react'

import { useRouter } from 'next/navigation'

import { onAuthStateChanged } from 'firebase/auth'

import { CircularProgress } from '@mui/material'

import axios from 'axios'

import { auth } from '@/libs/firebase'
import { baseURL } from '@/config'

const ClientAuthGuard = ({ children }) => {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [authenticated, setAuthenticated] = useState(false);

  //  const checkLogin = async ()=>{
  //   const  response  = await axios.get(`${baseURL}/api/admin/login`);

  //   if(response.data.login){
  //      router.replace('/login')
  //   }else{
  //      router.replace('/register')
  //   }
  // }

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, user => {
      const isAuthPath =
        window.location.pathname === '/' ||

        window.location.pathname === '/login' ||
        window.location.pathname === '/register' ||
        window.location.pathname === '/forgot-password' ||
        window.location.pathname.startsWith('/reset-password')

      if (user) {
        // User is authenticated
        if (isAuthPath) {
          // Redirect to dashboard if trying to access auth pages while logged in
          console.log('Dashboard')
          
          // router.replace('/dashboard')

        } else {
          // Allow access to protected pages
          setAuthenticated(true)
        }
      } else {
        // User is not authenticated
        if (!isAuthPath) {
          // Redirect to login if trying to access protected pages
          console.log('Login')
          router.replace('/')

          // checkLogin()
        } else {
          // Allow access to auth pages
          setAuthenticated(true)
        }
      }

      setTimeout(() => {
        setLoading(false)
      }, 1000)
    })

    return () => unsubscribe()
  }, [router])

  if (loading) {
    return (
      <div className='flex justify-center items-center min-h-screen fixed inset-0 bg-white' style={{ zIndex: 9999 }}>
        <CircularProgress />
      </div>
    )
  }

  return authenticated ? children : null
}

export default ClientAuthGuard
