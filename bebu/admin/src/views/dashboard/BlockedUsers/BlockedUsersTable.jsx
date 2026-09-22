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
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import Paper from '@mui/material/Paper'
import { Button } from '@mui/material'

// Components
import { getFullImageUrl } from '@/utils/commonfunctions'

const BlockedUsersTable = ({ blockedUsers }) => {
  const [showAll, setShowAll] = useState(false)

  const formatDate = dateString => {
    const date = new Date(dateString)

    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      hour12: true
    })
  }

  if (!blockedUsers || blockedUsers.length === 0) {
    return null
  }

  const displayedBlockedUsers = showAll ? blockedUsers : blockedUsers.slice(0, 5)

  return (
    <Card>
      <CardHeader title='Blocked Users' titleTypographyProps={{ sx: { fontWeight: 600, fontSize: '1.25rem' } }} />
      <CardContent sx={{ p: 0 }}>
        <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>User</TableCell>
                <TableCell>Gender</TableCell>
                <TableCell>Country</TableCell>
                <TableCell>Date Joined</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {displayedBlockedUsers.length > 0 ? (
                displayedBlockedUsers.map(user => (
                  <TableRow key={user._id}>
                    {/* User Info */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={2}>
                        <Avatar src={getFullImageUrl(user.image)} alt={user.name} />
                        <Box>
                          <Typography fontWeight={600}>{user.name}</Typography>
                          <Box display='flex' alignItems='center' gap={1}>
                            <Typography variant='body2'>
                              {user.userName.startsWith('@') ? user.userName : `@${user.userName}`}
                            </Typography>
                          </Box>
                        </Box>
                      </Box>
                    </TableCell>

                    {/* Gender */}
                    <TableCell>
                      {user.gender ? (
                        <Chip
                          size='small'
                          label={user.gender}
                          color={user.gender?.toLowerCase() === 'male' ? 'primary' : 'error'}
                          variant='tonal'
                        />
                      ) : (
                        <Typography variant='body2'>N/A</Typography>
                      )}
                    </TableCell>

                    {/* Country Info */}
                    <TableCell>
                      {user.country ? (
                        <Box display='flex' alignItems='center' gap={1}>
                          <img src={user.countryFlagImage} alt={user.country} width={25} height={15} />
                          <Typography variant='body2'>{user.country}</Typography>
                        </Box>
                      ) : (
                        <Typography variant='body2'>N/A</Typography>
                      )}
                    </TableCell>

                    {/* Created Date */}
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                        {formatDate(user.createdAt)}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={5} className='text-center'>
                    No blocked users found
                  </TableCell>
                </TableRow>
              )}
              {blockedUsers.length > 5 && !showAll && (
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

export default BlockedUsersTable
