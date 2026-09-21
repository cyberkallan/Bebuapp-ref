import axios from 'axios'

import { secretKey, baseURL } from '@/config'


export async function fetchFromBackend(
  req,
  {
    path,
    method = 'GET',
    includeBody = false // for POST, PUT
  } = {}
) {
  const headers = req.headers
  const token = headers.get('Authorization')
  const uid = headers.get('x-admin-uid')

  const url = new URL(req.url)
  const params = Object.fromEntries(url.searchParams.entries())

  let data = undefined

  if (includeBody && ['POST', 'PUT', 'PATCH'].includes(method.toUpperCase())) {
    const body = await req.json()

    data = body
  }

  try {
    const response = await axios({
      url: `${baseURL}${path}`,
      method,
      headers: {
        Authorization: token,
        'x-admin-uid': uid,
        key: secretKey
      },
      params,
      data
    })

    return { data: response.data, error: null }
  } catch (error) {
    console.error('fetchFromBackend error:', error?.response?.data || error.message)
    
    return {
      data: null,
      error: error?.response?.data?.message || 'Internal server error'
    }
  }
}
