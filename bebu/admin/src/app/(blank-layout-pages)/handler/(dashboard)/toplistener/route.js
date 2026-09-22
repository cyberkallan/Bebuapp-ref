import { NextResponse } from 'next/server'

import { fetchFromBackend } from '@/utils/fetchFromBackend'

export async function GET(req) {
  // const headers = req.headers
  // const token = headers.get('Authorization')
  // const uid = headers.get('x-admin-uid')
  // const path = headers.get('path')

  // const { searchParams } = new URL(req.url)
  // const startDate = searchParams.get('startDate') || 'All'
  // const endDate = searchParams.get('endDate') || 'All'

  // try {
  //   const response = await axios.get(`${baseURL}/api/admin/dashboard/getTopPerformingListeners`, {
  //     headers: {
  //       Authorization: token,
  //       'x-admin-uid': uid,
  //       key: secretKey
  //     },
  //     params: {
  //       startDate,
  //       endDate
  //     }
  //   })
  //   return NextResponse.json(response.data)
  // } catch (error) {
  //   console.log("error-->" , error);
  //   return NextResponse.json({ error: error?.response?.data?.message || 'Failed to fetch metrics' }, { status: 500 })
  // }

  const { data, error } = await fetchFromBackend(req, {
    path: '/api/admin/dashboard/getTopPerformingListeners'
  })

  if (error) {
    return NextResponse.json({ error }, { status: 500 })
  }

  return NextResponse.json(data)
}
