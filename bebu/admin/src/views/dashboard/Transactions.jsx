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

import { Button, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@mui/material'

// Components Imports
import { getFullImageUrl } from '@/utils/commonfunctions'
import { formatDate } from '@/utils/format'
import { handleCopy, truncateString } from '../apps/user/list/UserListTable'

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

const RecentUsers = ({ recentUsers }) => {
  const [showAll, setShowAll] = useState(false)

  const displayedRecentUsers = showAll ? recentUsers : recentUsers.slice(0, 5)

  return (
    <Card>
      <CardHeader
        title='Recent Users'
        titleTypographyProps={{ sx: { lineHeight: '2rem !important', letterSpacing: '0.15px !important' } }}
      />
      <CardContent className='p-0'>
         <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
          <Table>
             <TableHead>
              <TableRow className='uppercase'>
                <TableCell>User</TableCell>
                <TableCell>Nickname</TableCell>
                <TableCell>Gender</TableCell>
                <TableCell>Coin</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Login Type</TableCell>
                <TableCell>Date</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
               {displayedRecentUsers.length > 0 ? (
                displayedRecentUsers.map(item => (
                  <TableRow key={item._id}>
                    {/* itemer Info */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={2}>
                        <Avatar src={getFullImageUrl(item?.profilePic)} alt={item?.fullName} />
                        <Box>
                          <Typography fontWeight={600} title={item?.fullName}>
                            {item?.fullName > 15
                              ? `${item?.fullName.slice(0, 15)}...`
                              : item?.fullName}
                          </Typography>
                          <Typography className='cursor-pointer body2' onClick={()=>handleCopy(item?.email)}> {item?.loginType !== 2 ? item?.email : truncateString(item?.email, 15)}</Typography>
                        </Box>
                      </Box>
                    </TableCell>
                   
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                        {item?.nickName || "-"}
                      </Typography>
                      
                    </TableCell>
                    <TableCell>
                      <Typography variant='caption' color='text.secondary' textTransform={'capitalize'}>
                        {item?.gender || "-"}
                      </Typography>
                      
                    </TableCell>
                     <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                         {item?.coins || "0"}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      {
                        item?.isOnline ? (
                          <Chip
                            size='small'
                            label='Online'
                            color='success'
                            variant='tonal'
                          />
                        ) : (
                          <Chip
                            size='small'
                            label='Offline'
                            color='error'
                            variant='tonal'
                          />
                        )
                      }
                    
                    </TableCell>
                   
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                         <Chip
                            size='small'
                            label={LoginType[item?.loginType] || 'Unknown'}
                            color={LoginTypeColor[item?.loginType] || 'default'}
                          
                            variant='tonal'
                          />
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                        {formatDate(item?.createdAt)}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={12} className='text-center'>
                   No Data Found
                  </TableCell>
                </TableRow>
              )}
              {displayedRecentUsers.length > 5 && !showAll && (
                <Box mt={4} className='text-center'>
                  <Button variant='outlined' size='small' onClick={() => setShowAll(true)}>
                    Show More
                  </Button>
                </Box>
              )}
              {showAll && (
                <Box mt={4} className='text-center'>
                  <Button variant='outlined' size='small' onClick={() => setShowAll(false)}>
                    Show Less
                  </Button>
                </Box>
              )}
            </TableBody>
            </Table>

         </TableContainer>
        
        
      </CardContent>
    </Card>
  )
}

export default RecentUsers
