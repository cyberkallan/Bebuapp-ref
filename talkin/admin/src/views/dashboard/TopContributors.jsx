'use client'
import { useState } from 'react'

// MUI Imports
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Avatar from '@mui/material/Avatar'
import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Button from '@mui/material/Button'

import { getFullImageUrl } from '@/utils/commonfunctions'
import { LoginType, LoginTypeColor } from '@/constants'

const TopContributors = ({ topContributors }) => {
  const [showAll, setShowAll] = useState(false)

  // Only show first 5 users initially
  const displayedContributors = showAll ? topContributors : topContributors.slice(0, 5)

  return (
    <Card>
      <CardHeader
        title='Top Contributors'
        titleTypographyProps={{ sx: { lineHeight: '2rem !important', letterSpacing: '0.15px !important' } }}
      />
      <CardContent>
        {displayedContributors.length > 0
          ? displayedContributors.map((user, index) => (
              <Box key={index} className='flex items-center mb-6 last:mb-0'>
                <Avatar src={getFullImageUrl(user.profilePic)} alt={user.fullName} className='me-3' />
                <Box className='flex flex-col flex-grow'>
                  <Box className='flex items-center justify-between mb-0.5'>
                    <div>
                      <div className='flex items-center gap-2 mb-0.5'>
                        <Typography className='font-medium'>{user.fullName}</Typography>
                        <Chip
                          size='small'
                          label={LoginType[user?.loginType]}
                          color={LoginTypeColor[user?.loginType]}
                          variant='tonal'
                        />
                      </div>
                      <Typography className='text-sm'>{`@${user?.nickName}`}</Typography>
                      <Typography className='text-sm'>{`${user?.uniqueId}`}</Typography>
                    </div>
                    <div>
                      <Typography variant='h6' color='primary'>
                        {user?.totalCoinsSpent} coins
                      </Typography>
                      <Box className='flex items-center gap-2'>
                        {user.isOnline ? (
                          <Chip size='small' label='Online' color='success' variant='tonal' />
                        ) : (
                          <Chip size='small' label='Offline' color='error' variant='tonal' />
                        )}
                      </Box>
                    </div>
                  </Box>
                </Box>
              </Box>
            ))
          : '  No Data Found'}
        {/* </Box> */}

        {/* Show More Button */}
        {topContributors.length > 5 && !showAll && (
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

export default TopContributors
