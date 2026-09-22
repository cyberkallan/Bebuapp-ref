'use client'
import { useState } from 'react'

// MUI Imports
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import Avatar from '@mui/material/Avatar'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import List from '@mui/material/List'
import ListItem from '@mui/material/ListItem'
import ListItemAvatar from '@mui/material/ListItemAvatar'
import ListItemText from '@mui/material/ListItemText'
import { useTheme } from '@mui/material/styles'
import { Button } from '@mui/material'

// Import utils
import { getFullImageUrl } from '@/utils/commonfunctions'

const TopPerformanceListeners = ({ topPerformanceListeners }) => {
  const [showAll, setShowAll] = useState(false)
  const theme = useTheme()

  const displayedLikers = showAll ? topPerformanceListeners : topPerformanceListeners.slice(0, 5)

  return (
    <Card>
      <CardHeader
        title='Top Listeners'
        titleTypographyProps={{ sx: { lineHeight: '2rem !important', letterSpacing: '0.15px !important' } }}
      />
      <CardContent>
        {displayedLikers.length > 0
          ? displayedLikers.map((user, index) => (
              <Box key={index} className='flex items-center mb-6 last:mb-0'>
                <Avatar src={getFullImageUrl(user.image)} alt={user.fullName} className='me-3' />
                <Box className='flex flex-col flex-grow'>
                  <Box className='flex items-center justify-between mb-0.5'>
                    <div>
                      <div className='flex items-center gap-2 mb-0.5'>
                        <Typography className='font-medium'>{user.name}</Typography>
                      </div>
                      <Typography className='text-sm'>{`@${user?.nickName}`}</Typography>
                    </div>
                    <Typography variant='h6' color='primary'>
                      {user?.totalCoinReceived} coins
                    </Typography>
                  </Box>
                  <Box className='flex items-center justify-between'>
                    <Typography variant='caption' className='text-textSecondary'>
                      {user.uniqueId}
                    </Typography>
                    <Box className='flex items-center gap-2'>
                      {user.isOnline ? (
                        <Chip size='small' label='Online' color='success' variant='tonal' />
                      ) : (
                        <Chip size='small' label='Offline' color='error' variant='tonal' />
                      )}
                    </Box>
                  </Box>
                </Box>
              </Box>
            ))
          : '  No Data Found'}
        {/* </Box> */}

        {/* Show More Button */}
        {displayedLikers.length > 5 && !showAll && (
          <Box mt={4} className='text-center'>
            <Button variant='outlined' size='small' onClick={() => setShowAll(true)}>
              Show More
            </Button>
          </Box>
        )}

        {/* show less button */}
        {showAll && (
          <Box mt={4} className='text-center'>
            <Button variant='outlined' size='small' onClick={() => setShowAll(false)}>
              Show Less
            </Button>
          </Box>
        )}
      </CardContent>
    </Card>
  )
}

export default TopPerformanceListeners
