// MUI Imports

import { useState } from 'react'

import { Chip, Switch } from '@mui/material'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

import { getFormattedDate } from '@/utils/commonfunctions'
import { baseURL } from '@/config'
import { handleCopy, truncateString } from '@/views/apps/user/list/UserListTable'

const AboutOverview = ({ data }) => {
  // const { userDetails } = useSelector(state => state.userReducer)

  const [userDetails, setUserDetails] = useState(
    localStorage.getItem('selectedListener') ? JSON.parse(localStorage.getItem('selectedListener')) : null
  )

  console.log('userDetails-->', userDetails)

  if (userDetails?.isFake) {
    return (
      <Grid container spacing={6}>
        <Grid size={{ xs: 6 }} spacing={6} gap={4}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Personal Information
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-mail' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Email :</Typography>
                    <Typography className='cursor-pointer' onClick={()=>handleCopy(userDetails?.email)}> {truncateString(userDetails?.email, 40)}</Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>

                <div className='flex items-center gap-2'>
                  <i className='tabler-old' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Age :</Typography>
                    <Typography> {userDetails?.age || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Coin :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || '0'}</Typography>
                  </div>
                </div>

                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-language' />
                    <div className=''>
                      <Typography className='font-medium'>Languages :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.language?.length &&
                      userDetails?.language.map((item, i) => {
                        return <Chip label={item} key={i} color='warning' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-brand-kako-talk' />
                    <div className=''>
                      <Typography className='font-medium'>Talk Topics :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.talkTopics?.length &&
                      userDetails?.talkTopics.map((item, i) => {
                        return <Chip label={item} key={i} color='info' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-user-exclamation' />
                    <div className=''>
                      <Typography className='font-medium'>Self Introduction : </Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    <p>{userDetails?.selfIntro || 'No self introduction provided.'}</p>
                  </div>
                </div>
              </div>
              {userDetails?.experience && (
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Experience
                  </Typography>
                  <p>{userDetails?.experience || 'No experience provided.'}</p>
                </div>
              )}
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Availability & Status
                </Typography>

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
            </CardContent>
          </Card>
          {userDetails?.audio && (
            <Card className='mt-4'>
              <CardContent className='flex flex-col gap-6'>
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Audio
                  </Typography>
                  <div className='flex gap-2 flex-wrap'>
                    {userDetails?.audio && (
                      <div className='flex items-center gap-4'>
                        <audio controls className='rounded'>
                          <source src={baseURL + '/' + userDetails?.audio} />
                          Your browser does not support the audio tag.
                        </audio>
                      </div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </Grid>
        <Grid size={{ xs: 6 }}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Call Rates (in Coins)
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Video Call :</Typography>
                    <Typography> {userDetails?.ratePrivateVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Audio Call:</Typography>
                    <Typography> {userDetails?.ratePrivateAudioCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Random Video Call:</Typography>
                    <Typography> {userDetails?.rateRandomVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Random Audio Call:</Typography>
                    <Typography> {userDetails?.rateRandomAudioCall || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Performance Metrics
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Rating :</Typography>
                    <Typography> {userDetails?.rating || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-eye-discount' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Count:</Typography>
                    <Typography> {userDetails?.reviewCount || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-phone-done' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Call count :</Typography>
                    <Typography> {userDetails?.callCount || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-crown' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Experience :</Typography>
                    <Typography> {userDetails?.experience || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Metadata
                </Typography>
                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-michelin-star' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Date:</Typography>
                    <Typography> {getFormattedDate(userDetails?.reviewAt) || '-'}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Video
                </Typography>
                <div className='flex gap-2 flex-wrap'>
                  {userDetails?.video.map((item, i) => {
                    return (
                      <div key={i} className='flex items-center gap-4 border rounded'>
                        <video width='125' height={125} controls className='rounded'>
                          <source src={baseURL + '/' + item} />
                          Your browser does not support the video tag.
                        </video>
                      </div>
                    )
                  })}
                </div>
              </div>
            </CardContent>
          </Card>
          
        </Grid>
      </Grid>
    )
  } else {
    return (
      <Grid container spacing={6}>
        <Grid size={{ xs: 12 }}>
          <Card>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Personal Information
                </Typography>
                <div className='flex items-center gap-2'>
                  <i className='tabler-mail' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Email:</Typography>
                   <Typography className='cursor-pointer' onClick={()=>handleCopy(userDetails?.email)}> { truncateString(userDetails?.email, 40)}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-id' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Unique Id :</Typography>
                    <Typography> {userDetails?.uniqueId || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-old' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Age :</Typography>
                    <Typography> {userDetails?.age || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Coin :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || '0'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Rating :</Typography>
                    <Typography> {userDetails?.rating || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-phone-done' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Call count :</Typography>
                    <Typography> {userDetails?.callCount || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-stars' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Current Coin :</Typography>
                    <Typography> {userDetails?.currentCoinBalance || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-michelin-star' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Date:</Typography>
                    <Typography> {getFormattedDate(userDetails?.reviewAt) || '-'}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-eye-discount' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Review Count:</Typography>
                    <Typography> {userDetails?.reviewCount || '0'}</Typography>
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

                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-brand-kako-talk' />
                    <div className=''>
                      <Typography className='font-medium'>Talk Topics :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.talkTopics?.length &&
                      userDetails?.talkTopics.map((item, i) => {
                        return <Chip label={item} key={i} color='info' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
                <div className=''>
                  <div className='flex items-center gap-2'>
                    <i className='tabler-language' />
                    <div className=''>
                      <Typography className='font-medium'>Languages :</Typography>
                    </div>
                  </div>
                  <div className='flex items-center flex-wrap gap-2 mt-3'>
                    {userDetails?.language?.length &&
                      userDetails?.language.map((item, i) => {
                        return <Chip label={item} key={i} color='warning' variant='tonal' size='small' />
                      })}
                  </div>
                </div>
              </div>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Self Introduction
                </Typography>
                <p>{userDetails?.selfIntro || 'No self introduction provided.'}</p>
              </div>
              {userDetails?.experience && (
                <div className='flex flex-col gap-4'>
                  <Typography className='uppercase' variant='body2' color='text.disabled'>
                    Experience
                  </Typography>
                  <p>{userDetails?.experience || 'No experience provided.'}</p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <Typography className='uppercase' variant='body2' color='text.disabled'>
                Availability For Calls
              </Typography>
              <div className='flex flex-col gap-4'>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Private Audio Call :</Typography>
                    <Chip
                      label={userDetails?.isAvailableForPrivateAudioCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForPrivateAudioCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Private Video Call:</Typography>
                    <Chip
                      label={userDetails?.isAvailableForPrivateVideoCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForPrivateVideoCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Random Audio Call:</Typography>
                    <Chip
                      label={userDetails?.isAvailableForRandomAudioCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForRandomAudioCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Available For Random Video Call:</Typography>
                    <Chip
                      label={userDetails?.isAvailableForRandomVideoCall ? 'Available' : 'Not Abailable'}
                      color={userDetails?.isAvailableForRandomVideoCall ? 'success' : 'error'}
                      variant='tonal'
                      size='small'
                    />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className='mt-4'>
            <CardContent className='flex flex-col gap-6'>
              <div className='flex flex-col gap-4'>
                <Typography className='uppercase' variant='body2' color='text.disabled'>
                  Call Rates (in Coins)
                </Typography>

                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Video Call :</Typography>
                    <Typography> {userDetails?.ratePrivateVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Private Audio Call:</Typography>
                    <Typography> {userDetails?.ratePrivateAudioCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Random Video Call:</Typography>
                    <Typography> {userDetails?.rateRandomVideoCall || 0}</Typography>
                  </div>
                </div>
                <div className='flex items-center gap-2'>
                  <i className='tabler-coin' />
                  <div className='flex items-center flex-wrap gap-2'>
                    <Typography className='font-medium'>Random Audio Call: </Typography>
                    <Typography> {userDetails?.rateRandomAudioCall || 0}</Typography>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    )
  }
}

export default AboutOverview
