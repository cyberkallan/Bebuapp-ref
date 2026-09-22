
import { Badge, styled } from '@mui/material'

import { baseURL } from '@/config'

export const getFullImageUrl = imgPath => {
  if (!imgPath) return ''

  const cleanPath = imgPath.replace(/^storage[\\\/]/, '')
  
  if (imgPath.includes('storage')) {
    return `${baseURL}/storage/${cleanPath}`
  } else {
    return cleanPath
  }
}

export const getUserViewUrl = userId => {
  return `/apps/user/view?userId=${userId}`
}

export const SmallBadge = styled(Badge)(({ theme }) => ({
  '& .MuiBadge-badge': {
    fontSize: '10px',
    height: '16px',
    minWidth: '16px',
    padding: '0 4px',
    top: '5px',
    right: '5px'
  }
}))

export const getRoleDetails = role => {
  switch (role) {
    case 1:
      return { label: 'User', icon: 'tabler-user', color: 'primary' }
    case 2:
      return { label: 'Host', icon: 'tabler-users-plus', color: 'success' }
    case 3:
      return { label: 'Agency', icon: 'tabler-users-group', color: 'warning' }
    case 4:
      return { label: 'CoinTrader', icon: 'tabler-coins', color: 'info' }
    default:
      return { label: 'Unknown', icon: 'tabler-alert-circle', color: 'error' }
  }
}

export const getFormattedDate = date => {
  if (!date) return '-'

  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hour12: true
  })
}
