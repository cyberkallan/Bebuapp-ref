'use client'

// Component Imports
import { useEffect, useState } from 'react'

import axios from 'axios'

import { baseURL, projectName } from '@/config'
import Login from '@/views/auth/Login'
import Registration from '@/views/auth/Registration'

const LoginPage = () => {
  const [login, setLogin] = useState(false)
  const [loading, setLoading] = useState(true)

  const checkLogin = async () => {
    const response = await axios.get(`${baseURL}/api/admin/login`)

    if (response.data.login) {
      setLogin(true)
      setLoading(false)
    } else {
      setLogin(false)
      setLoading(false)
    }
  }

  useEffect(() => {
    checkLogin()
  }, [])

  return loading ? (
    <div className='flex justify-center items-center min-h-screen'>
      <p>Loading...</p>
    </div>
  ) : login ? (
    <Login />
  ) : (
    <Registration />
  )

}

export default LoginPage
