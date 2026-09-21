import axios from 'axios'

import { baseURL } from '@/config'

export const apiClient = (token, uid) => {
  return axios.create({
    baseURL: baseURL + '/api/admin',
    headers: {
      key: process.env.secretKey,
      Authorization: `Bearer ${token}`,
      'x-admin-uid': uid
    },
    withCredentials: true
  })
}
