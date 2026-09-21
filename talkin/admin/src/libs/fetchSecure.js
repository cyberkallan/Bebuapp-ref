// /libs/fetchSecure.js
import { secretKey, baseURL } from '@/config'

export async function fetchSecure({ token, url, method = 'GET', body = null, customHeaders = {} }) {
  // const token = req.cookies.get('token')?.value

  if (!token) return { success: false, error: 'No token found' }

  const headers = {
    'Content-Type': 'application/json',
    key: secretKey,
    Authorization: `Bearer ${token}`,
    ...customHeaders
  }

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    })

    const data = await res.json()

    if (!res.ok) return { success: false, error: data.message || 'API failed' }

    return { success: true, data }
  } catch (err) {
    return { success: false, error: err.message }
  }
}
