// MUI Imports

import { Chip } from '@mui/material'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

import { getFormattedDate } from '@/utils/commonfunctions'
import { handleCopy, truncateString } from '../../../list/UserListTable'

const LoginType = {
  1: 'Google',
  2: 'Quick',
  3: 'Mobile Number',
  4: 'Email'
}

const LoginTypeColor = {
  1: 'error',
  2: 'info',
  3: 'warning',
  4: 'success'
}

const AboutOverview = ({ data }) => {
  // const { userDetails } = useSelector(state => state.userReducer)
  const userDetails = localStorage.getItem('selectedUser') ? JSON.parse(localStorage.getItem('selectedUser')) : {}

  console.log('userDetails--->', userDetails)

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <Card>
          <CardContent className='flex flex-col gap-6'>
            <div className='flex flex-col gap-4'>
              <Typography className='uppercase' variant='body2' color='text.disabled'>
                About
              </Typography>
              <div className='flex items-center gap-2'>
                <i className='tabler-user' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Nickname :</Typography>
                  <Typography> {userDetails?.nickName || '-'}</Typography>
                </div>
              </div>
              {/* <div className='flex items-center gap-2'>
                <i className='tabler-user' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Age :</Typography>
                  <Typography> {userDetails?.age || "-"}</Typography>
                </div>
              </div> */}
              <div className='flex items-center gap-2'>
                <i className='tabler-mail' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Email :</Typography>
                  <Typography className='cursor-pointer' onClick={()=>handleCopy(userDetails?.email)}> {userDetails?.loginType !== 2 ? userDetails?.email : truncateString(userDetails?.email, 25)}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-phone' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Phone :</Typography>
                  <Typography> {userDetails?.phoneNumber || '-'}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-flag' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Country :</Typography>
                  <Typography> {userDetails?.country || '-'}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-crown' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Role :</Typography>
                  <Typography> {userDetails?.isListener ? 'Listener' : 'User'}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-id' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Unique Id :</Typography>
                  <Typography> {userDetails?.uniqueId}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-key' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Last Login:</Typography>
                  <Typography> {getFormattedDate(userDetails?.lastlogin) || '-'}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-calendar-bolt' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Create At:</Typography>
                  <Typography> {getFormattedDate(userDetails?.createdAt) || '-'}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-wifi' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Status :</Typography>

                  {userDetails?.isOnline ? (
                    <Chip label='Online' color='success' variant='tonal' size='small' />
                  ) : (
                    <Chip label='Offline' color='error' variant='tonal' size='small' />
                  )}
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-bell' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Busy :</Typography>

                  {!userDetails?.isBusy ? (
                    <Chip label='Available' color='success' variant='tonal' size='small' />
                  ) : (
                    <Chip label='Busy' color='error' variant='tonal' size='small' />
                  )}
                </div>
              </div>
              {userDetails?.isBlocked ? (
                <div className='flex items-center gap-2'>
                  <i className='tabler-bell' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Blocked :</Typography>
                    <Chip label='Blocked' color='error' variant='tonal' size='small' />
                  </div>
                </div>
              ) : (
                ''
              )}
              <div className='flex items-center gap-2'>
                <i className='tabler-logic-and' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Login Type :</Typography>
                  <Chip
                    label={LoginType[userDetails?.loginType]}
                    color={LoginTypeColor[userDetails?.loginType]}
                    variant='tonal'
                    size='small'
                  />
                </div>
              </div>
            </div>
            <div className='flex flex-col gap-4'>
              <Typography className='uppercase' variant='body2' color='text.disabled'>
                Coin
              </Typography>
              <div className='flex items-center gap-2'>
                <i className='tabler-coin ' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Coin :</Typography>
                  <Typography className='text-succes'> {userDetails?.coins || 0}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-coin' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Coin Spent :</Typography>
                  <Typography className='text-erro'> {userDetails?.coinsSpent || 0}</Typography>
                </div>
              </div>
              <div className='flex items-center gap-2'>
                <i className='tabler-coin ' />
                <div className='flex items-center flex-wrap gap-2'>
                  <Typography className='font-medium'>Coin Recharged :</Typography>
                  <Typography className='text-inf'> {userDetails?.coinsRecharged || 0}</Typography>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default AboutOverview
