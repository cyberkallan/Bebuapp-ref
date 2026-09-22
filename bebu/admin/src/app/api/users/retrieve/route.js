export const dynamic = 'force-dynamic'

import { headers } from 'next/headers'
import { NextResponse } from 'next/server'

import { parse } from 'cookie'

import { fetchSecure } from '@/libs/fetchSecure'

export async function GET(req) {
  const { searchParams } = new URL(req.url)
  const page = searchParams.get('page') || 1
  const limit = searchParams.get('limit') || 10
  const search = searchParams.get('search') || 'ALL'

  const url = `${baseURL}/api/admin/user/getUsers?start=${page}&limit=${limit}&search=${search}&startDate=ALL&endDate=ALL`

  const result = await fetchSecure({ url })

  if (!result.success) {
    return NextResponse.json({ success: false, error: result.error }, { status: 401 })
  }

  return NextResponse.json({ success: true, ...result.data })
}
