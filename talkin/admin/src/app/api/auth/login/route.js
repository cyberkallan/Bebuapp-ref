import { NextResponse } from 'next/server'

import jwt from 'jsonwebtoken' // ✅ import this

import { secretKey, baseURL } from '@/config'

export async function POST(req) {
  const headers = req.headers

  const email = headers.get('x-email')
  const password = headers.get('x-password')
  const token = headers.get('x-token')
  const uid = headers.get('x-uid')

  if (!email || !password || !token || !uid) {
    return NextResponse.json({ success: false, error: 'Missing credentials' }, { status: 400 })
  }

  const backendRes = await fetch(`${baseURL}/api/admin/admin/adminLogin`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      key: secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    },
    body: JSON.stringify({ email, password })
  })

  const data = await backendRes.json()

  if (!data.status) {
    return NextResponse.json({ success: false, error: data.message || 'Login failed' }, { status: 401 })
  }

  // ✅ Decode the token received in data.data
  let decoded = null

  if (data.data) {
    try {
      decoded = jwt.decode(data.data)
    } catch (err) {
      console.error('Failed to decode token:', err)
    }
  }

  const response = NextResponse.json({
    success: true,
    user: { email: decoded?.email, name: decoded?.name, profileImage: decoded?.image } || {},
    message: data.message || 'Login successful'
  })

  // ✅ Set cookie
  if (data.data) {
    console.log('entered to set cookie', response)
    response.cookies.set({
      name: 'token',
      value: data.data,
      httpOnly: true,
      sameSite: 'strict',
      path: '/'
    })
  }

  console.log('Set-Cookie Header:', response.headers.get('set-cookie'))

  return response
}
