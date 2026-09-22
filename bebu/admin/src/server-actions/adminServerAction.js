'use server'

import axios from 'axios'

export async function callNextLoginAPI({ email, password, token, uid }) {
  try {
    const response = await axios.post(
      `${process.env.NEXTAUTH_URL}/api/auth/login`,
      { email, password, token, uid },
      {
        headers: {
          'Content-Type': 'application/json'
        },
        withCredentials: true
      }
    )

    return response.data
  } catch (error) {
    console.error('❌ Axios error:', error?.response?.data || error.message)

    return {
      success: false,
      error: error?.response?.data?.error || 'Server error'
    }
  }
}
