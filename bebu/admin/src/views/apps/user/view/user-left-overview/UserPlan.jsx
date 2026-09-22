'use client'

// React Imports
import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import Typography from '@mui/material/Typography'
import LinearProgress from '@mui/material/LinearProgress'
import Button from '@mui/material/Button'
import Avatar from '@mui/material/Avatar'
import Box from '@mui/material/Box'

// Component Imports
import CustomAvatar from '@core/components/mui/Avatar'
import { getAllLevels } from '@/redux-store/slices/wealthLevels'
import { getFullImageUrl } from '@/utils/commonfunctions'

const UserPlan = ({ userDetails }) => {
  const dispatch = useDispatch()
  const { levels } = useSelector(state => state.wealthLevelReducer || { levels: [] })
  const [wealthLevel, setWealthLevel] = useState(null)
  const [nextLevel, setNextLevel] = useState(null)
  const [progressPercentage, setProgressPercentage] = useState(0)

  useEffect(() => {
    if (userDetails.wealthLevel) {
      dispatch(getAllLevels())
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (levels?.length > 0 && userDetails?.wealthLevel) {
      const userWealthLevel = levels.find(level => level._id === userDetails.wealthLevel)

      setWealthLevel(userWealthLevel)

      if (userWealthLevel) {
        // Find the next level
        const sortedLevels = [...levels].sort((a, b) => a.level - b.level)
        const currentLevelIndex = sortedLevels.findIndex(level => level._id === userWealthLevel._id)

        if (currentLevelIndex >= 0 && currentLevelIndex < sortedLevels.length - 1) {
          setNextLevel(sortedLevels[currentLevelIndex + 1])
        }

        // Calculate progress percentage
        if (userDetails.coin && nextLevel) {
          const currentThreshold = userWealthLevel.coinThreshold
          const nextThreshold = nextLevel.coinThreshold
          const coinsNeeded = nextThreshold - currentThreshold
          const userProgress = userDetails.topUpCoin - currentThreshold

          const percentage = Math.min(Math.max((userProgress / coinsNeeded) * 100, 0), 100)

          setProgressPercentage(percentage)
        }
      }
    }
  }, [levels, userDetails, nextLevel])

  if (!wealthLevel) {
    return null
  }

  return (
    <>
      <Card className='border-2 border-primary rounded shadow-primarySm'>
        <CardContent className='flex flex-col gap-6'>
          <div className='flex justify-between items-center'>
            <div className='flex items-center gap-3'>
              {wealthLevel.levelImage && (
                <img
                  src={getFullImageUrl(wealthLevel.levelImage)}
                  alt='Wealth Level'
                  className='rounded-md object-contain'
                  style={{ height: '40px', width: 'auto', maxWidth: '70px' }}
                />
              )}
              <div className='flex gap-1'>
                <Chip label={wealthLevel.levelName} size='small' color='primary' variant='tonal' />
                <Typography variant='caption' display='block'>
                  Level {wealthLevel.level}
                </Typography>
              </div>
            </div>
            <div className='flex justify-center gap-1'>
              <Typography component='span' variant='h6' color='primary.main'>
                {wealthLevel.coinThreshold}
              </Typography>
              <Typography component='sub' className='self-end' color='text.primary'>
                coins
              </Typography>
            </div>
          </div>

          <div className='flex flex-col gap-2'>
            <div className='flex items-center gap-2'>
              <i className='tabler-coin text-secondary' />
              <Typography component='span'>Current Coins: {userDetails?.coin || 0}</Typography>
            </div>
            {wealthLevel?.permissions &&
              Object.entries(wealthLevel.permissions).map(([key, value]) => (
                <div key={key} className='flex items-center gap-2'>
                  <i className={`tabler-${value ? 'circle-check' : 'circle-x'} text-${value ? 'success' : 'error'}`} />
                  <Typography component='span'>
                    {key
                      .replace(/([A-Z])/g, ' $1')
                      .replace(/^./, str => str.toUpperCase())
                      .replace('Live Streaming', 'Live Streaming')
                      .replace('Free Call', 'Free Call')
                      .replace('Redeem Cashout', 'Redeem Cashout')
                      .replace('Upload Social Post', 'Upload Social Post')
                      .replace('Upload Video', 'Upload Video')}
                  </Typography>
                </div>
              ))}
          </div>

          {nextLevel && (
            <div className='flex flex-col gap-1'>
              <div className='flex items-center justify-between'>
                <Typography className='font-medium' color='text.primary'>
                  Progress to next level
                </Typography>
                <Typography className='font-medium' color='text.primary'>
                  {userDetails?.topUpCoin || 0} / {nextLevel.coinThreshold}
                </Typography>
              </div>
              <LinearProgress variant='determinate' value={progressPercentage} />
              <Box display='flex' justifyContent='space-between' mt={1}>
                <Typography variant='body2'>Current: {wealthLevel.levelName}</Typography>
                <Typography variant='body2'>Next: {nextLevel.levelName}</Typography>
              </Box>
            </div>
          )}
        </CardContent>
      </Card>
    </>
  )
}

export default UserPlan
