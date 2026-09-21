// 'use server'
import { secretKey } from '@/config'

// import { cookies } from 'next/headers'

export const getAuthHeaders = () => {
  // const cookiesStore = await cookies()
  // const token = cookiesStore.get('admin_token')?.value
  // const uid = cookiesStore.get('uid')?.value
  const token = localStorage.getItem('admin_token')
  const uid = localStorage.getItem('uid')

  return {
    'Content-Type': 'application/json',
    key: secretKey,
    Authorization: `Bearer ${token}`,
    'x-admin-uid': uid
  }
}
