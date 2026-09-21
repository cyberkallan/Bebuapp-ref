'use client'

import { useEffect, useState } from 'react'

// MUI Imports
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Chip from '@mui/material/Chip'
import Divider from '@mui/material/Divider'
import Button from '@mui/material/Button'

// Component Imports
import ConfirmationDialog from '@components/dialogs/confirmation-dialog'

import EditUserInfo from '@components/dialogs/edit-user-info'

import OpenDialogOnElementClick from '@components/dialogs/OpenDialogOnElementClick'

import CustomAvatar from '@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'

// Vars
const userData = {
  firstName: 'Seth',
  lastName: 'Hallam',
  userName: '@shallamb',
  billingEmail: 'shallamb@gmail.com',
  status: 'active',
  role: 'Subscriber',
  taxId: 'Tax-8894',
  contact: '+1 (234) 464-0600',
  language: ['English'],
  country: 'France',
  useAsBillingAddress: true
}

const UserDetails = ({ userDetails }) => {
  // Vars
  const buttonProps = (children, color, variant) => ({
    children,
    color,
    variant
  })

  const [userInfo, setUserInfo] = useState({})

  useEffect(() => {
    const data = typeof window !== 'undefined' && localStorage.getItem('user')

    setUserInfo(JSON.parse(data))
  }, [])

  // console.log(userInfo)

  return (
    <>
      <Card>
        <CardContent className='flex flex-col pbs-12 gap-6'>
          <div className='flex flex-col gap-6'>
            <div className='flex items-center justify-center flex-col gap-4'>
              <div className='w-full h-full'>
                <div className='flex flex-col items-center gap-4'>
                  <CustomAvatar
                    alt='user-profile'
                    src={getFullImageUrl(userDetails?.image) || '/images/avatars/1.png'}
                    variant='rounded'
                    size={120}
                  />
                  <Typography variant='h5'>{`${userDetails?.name}`}</Typography>
                </div>
              </div>
              <Chip
                label={
                  userDetails?.role === 1
                    ? 'User'
                    : userDetails?.role === 2
                      ? 'Host'
                      : userDetails?.role === 3
                        ? 'Agency'
                        : userDetails?.role === 4
                          ? 'Coin Trader'
                          : 'Unknown'
                }
                color='secondary'
                size='small'
                variant='tonal'
              />
            </div>
            <div className='flex items-center justify-evenly flex-wrap gap-4'>
              {!userDetails?.isFake && (
                <>
                  <div className='flex items-center gap-4'>
                    <CustomAvatar variant='rounded' color='success' skin='light'>
                      <i className='tabler-coin' />
                    </CustomAvatar>
                    <div>
                      <Typography variant='h5'>{userDetails?.receivedCoins || '0'}</Typography>
                      <Typography>Received Coins</Typography>
                    </div>
                  </div>
                  <div className='flex items-center gap-4'>
                    <CustomAvatar variant='rounded' color='error' skin='light'>
                      <i className='tabler-coin' />
                    </CustomAvatar>
                    <div>
                      <Typography variant='h5'>{userDetails?.spentCoins || '0'}</Typography>
                      <Typography>Spent Coins</Typography>
                    </div>
                  </div>
                </>
              )}
            </div>
          </div>
          {/* <div>
            <Typography variant='h5'>Details</Typography>
            <Divider className='mlb-4' />
            <div className='flex flex-col gap-2'>
              {!userDetails?.isFake && (
                <div className='flex items-center flex-wrap gap-x-1.5'>
                  <Typography className='font-medium' color='text.primary'>
                    Bio:
                  </Typography>
                  <Typography>{userDetails?.bio || '-'}</Typography>
                </div>
              )}
              <div className='flex items-center flex-wrap gap-x-1.5'>
                <Typography className='font-medium' color='text.primary'>
                  Username:
                </Typography>
                <Typography>{userDetails?.userName || '-'}</Typography>
              </div>
              <div className='flex items-center flex-wrap gap-x-1.5'>
                <Typography className='font-medium' color='text.primary'>
                  UniqueId:
                </Typography>
                <Typography>{userDetails?.uniqueId || '-'}</Typography>
              </div>
              <div className='flex items-center flex-wrap gap-x-1.5'>
                <Typography className='font-medium' color='text.primary'>
                  Email:
                </Typography>
                <Typography>{userDetails?.email || '-'}</Typography>
              </div>
              {!userDetails?.isFake && (
                <div className='flex items-center flex-wrap gap-x-1.5'>
                  <Typography className='font-medium' color='text.primary'>
                    Coins:
                  </Typography>
                  <Typography>{userDetails?.coin || '0'}</Typography>
                </div>
              )}
              <div className='flex items-center flex-wrap gap-x-1.5'>
                <Typography className='font-medium' color='text.primary'>
                  Gender:
                </Typography>
                <Typography>{userDetails?.gender || '-'}</Typography>
              </div>
              <div className='flex items-center flex-wrap gap-x-1.5'>
                <Typography className='font-medium' color='text.primary'>
                  Age:
                </Typography>
                <Typography>{userDetails?.age || '-'}</Typography>
              </div>
              {!userDetails?.isFake && (
                <>
                  <div className='flex items-center flex-wrap gap-x-1.5'>
                    <Typography className='font-medium' color='text.primary'>
                      Login Type:
                    </Typography>
                    <Typography>
                      {userDetails?.loginType === 1
                        ? 'Mobile No'
                        : userDetails?.loginType === 2
                          ? 'Google'
                          : userDetails?.loginType === 3
                            ? 'Quick'
                            : userDetails?.loginType === 4
                              ? 'Email'
                              : '-'}
                    </Typography>
                  </div>
                  <div className='flex items-center flex-wrap gap-x-1.5'>
                    <Typography className='font-medium' color='text.primary'>
                      Is VIP:
                    </Typography>
                    <Typography>{userDetails?.isVIP ? 'Yes' : 'No'}</Typography>
                  </div>
                  <div className='flex items-center flex-wrap gap-x-1.5'>
                    <Typography className='font-medium' color='text.primary'>
                      IP Address:
                    </Typography>
                    <Typography>{userDetails?.ipAddress || '-'}</Typography>
                  </div>
                  <div className='flex items-center flex-wrap gap-x-1.5'>
                    <Typography className='font-medium' color='text.primary'>
                      Last Login:
                    </Typography>
                    <Typography>{userDetails?.lastlogin || '-'}</Typography>
                  </div>
                </>
              )}
            </div>
          </div> */}
        </CardContent>
      </Card>
    </>
  )
}

export default UserDetails
