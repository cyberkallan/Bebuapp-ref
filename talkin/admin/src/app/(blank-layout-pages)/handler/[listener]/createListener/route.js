import { NextResponse } from 'next/server'

import { fetchFromBackend } from '@/utils/fetchFromBackend'

export async function GET(req) {
  const { data, error } = await fetchFromBackend(req, {
    path: '/api/admin/dashboard/fetchChartMetrics'
  })

  if (error) {
    return NextResponse.json({ error }, { status: 500 })
  }

  return NextResponse.json(data)
}
