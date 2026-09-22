'use client'

// React imports
import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Divider from '@mui/material/Divider'
import Chip from '@mui/material/Chip'

// Component Imports
import CustomAvatar from '@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'

/**
 * ! If you need data using an API call, uncomment the below API code, update the `process.env.API_URL` variable in the
 * ! `.env` file found at root of your project and also update the API endpoints like `/apps/invoice` in below example.
 * ! Also, remove the above server action import and the action itself from the `src/app/server/actions.ts` file to clean up unused code
 * ! because we've used the server action for getting our static data.
 */
/* const getInvoiceData = async () => {
  const res = await fetch(`${process.env.API_URL}/apps/invoice`)

  if (!res.ok) {
    throw new Error('Failed to fetch invoice data')
  }

  return res.json()
} */

const OverViewTab = ({ userDetails }) => {
  const dispatch = useDispatch()
  const { levels } = useSelector(state => state.wealthLevelReducer || { levels: [] })
  const [wealthLevel, setWealthLevel] = useState(null)

  // useEffect(() => {
  //   dispatch(getAllLevels())
  // }, [dispatch])

  useEffect(() => {
    if (levels?.length > 0 && userDetails?.wealthLevel) {
      const userWealthLevel = levels.find(level => level._id === userDetails.wealthLevel)

      setWealthLevel(userWealthLevel)
    }
  }, [levels, userDetails])

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <Card>
          <CardContent>
            <Typography variant='h5' className='mbe-4'>
              Account Information
            </Typography>
            <Divider className='mlb-4' />
            <Grid container spacing={4}>
              <Grid size={{ xs: 12, md: 6 }}>
                <div className='flex flex-col gap-4'>
                  <div>
                    <Typography color='text.secondary' className='text-sm'>
                      Account Created
                    </Typography>
                    <Typography>{new Date(userDetails?.createdAt).toLocaleString() || 'N/A'}</Typography>
                  </div>
                  {!userDetails?.isFake && (
                    <>
                      <div>
                        <Typography color='text.secondary' className='text-sm'>
                          Last Login
                        </Typography>
                        <Typography>{userDetails?.lastlogin || 'N/A'}</Typography>
                      </div>
                      <div>
                        <Typography color='text.secondary' className='text-sm'>
                          Identity / Device
                        </Typography>
                        <Typography>{userDetails?.identity || 'N/A'}</Typography>
                      </div>
                      <div>
                        <Typography color='text.secondary' className='text-sm'>
                          IP Address
                        </Typography>
                        <Typography>{userDetails?.ipAddress || 'N/A'}</Typography>
                      </div>
                    </>
                  )}
                </div>
              </Grid>
              <Grid size={{ xs: 12, md: 6 }}>
                <div className='flex flex-col gap-4'>
                  {!userDetails?.isFake && (
                    <div>
                      <Typography color='text.secondary' className='text-sm'>
                        Mobile Number
                      </Typography>
                      <Typography>{userDetails?.mobileNumber || 'N/A'}</Typography>
                    </div>
                  )}
                  <div>
                    <Typography color='text.secondary' className='text-sm'>
                      Country
                    </Typography>
                    <div className='flex items-center gap-2'>
                      {userDetails?.countryFlagImage &&
                        (userDetails.countryFlagImage.includes('.') ? (
                          <CustomAvatar
                            src={userDetails.countryFlagImage}
                            alt='Country Flag'
                            variant='rounded'
                            size={24}
                          />
                        ) : (
                          <Typography component='span'>{userDetails.countryFlagImage}</Typography>
                        ))}
                      <Typography>{userDetails?.country || 'N/A'}</Typography>
                    </div>
                  </div>
                  {!userDetails?.isFake && (
                    <div>
                      <Typography color='text.secondary' className='text-sm'>
                        Provider
                      </Typography>
                      <Typography>{userDetails?.provider || 'N/A'}</Typography>
                    </div>
                  )}
                </div>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default OverViewTab
