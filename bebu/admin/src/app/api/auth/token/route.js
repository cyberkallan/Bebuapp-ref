// src/app/api/auth/token/route.js

import { NextResponse } from 'next/server'

import { getToken } from 'next-auth/jwt'

export async function GET(req) {
  const token = await getToken({ req })

  if (!token || !token.accessToken) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  return NextResponse.json({ token: token.accessToken })
}
