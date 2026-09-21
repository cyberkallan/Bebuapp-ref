'use client'

// React Imports
import { useState } from 'react'

import { useSelector } from 'react-redux'

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
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'

// Components
import { getFullImageUrl } from '@/utils/commonfunctions'

const BlockedUsers = ({ reportedUsers }) => {
  const { blockedUsers } = useSelector(state => state.dashboard)
  const [activeTab, setActiveTab] = useState(0)

  // Handle tab change
  const handleTabChange = (event, newValue) => {
    setActiveTab(newValue)
  }

  // Helper Functions
  const getStatusColor = status => {
    switch (status) {
      case 1:
        return 'warning'
      case 2:
        return 'success'
      case 3:
        return 'error'
      default:
        return 'default'
    }
  }

  const getStatusLabel = status => {
    switch (status) {
      case 1:
        return 'Pending'
      case 2:
        return 'Resolved'
      case 3:
        return 'Rejected'
      default:
        return 'Unknown'
    }
  }

  const formatDate = dateString => {
    const date = new Date(dateString)

    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
  }

  return (
    <Card>
      <CardHeader title='User Management' titleTypographyProps={{ sx: { fontWeight: 600, fontSize: '1.25rem' } }} />
      <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
        <Tabs value={activeTab} onChange={handleTabChange} aria-label='user management tabs'>
          <Tab label='Reported Users' />
          <Tab label='Blocked Users' />
        </Tabs>
      </Box>
      <CardContent sx={{ p: 0 }}>
        {activeTab === 0 && reportedUsers && reportedUsers.length > 0 && (
          <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Reporter</TableCell>
                  <TableCell>Username</TableCell>
                  <TableCell>Reported User</TableCell>
                  <TableCell>Reason</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {reportedUsers.map(report => (
                  <TableRow key={report._id}>
                    {/* Reporter Info */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={2}>
                        <Avatar src={getFullImageUrl(report.userId.image)} alt={report.userId.name} />
                        <Box>
                          <Typography fontWeight={600}>{report.userId.name}</Typography>
                          <Box display='flex' alignItems='center' gap={1}>
                            <Typography variant='body2'>{report.userId.countryFlagImage}</Typography>
                            <Chip
                              size='small'
                              label={report.userId.gender}
                              color={report.userId.gender?.toLowerCase() === 'male' ? 'primary' : 'error'}
                              variant='tonal'
                            />
                          </Box>
                        </Box>
                      </Box>
                    </TableCell>

                    {/* Username */}
                    <TableCell>
                      <Typography variant='body2' color='text.secondary'>
                        @{report.userId.userName}
                      </Typography>
                    </TableCell>

                    {/* Reported User */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={1}>
                        <Avatar
                          src={getFullImageUrl(report.toUserId.image)}
                          alt={report.toUserId.name}
                          sx={{ width: 24, height: 24 }}
                        />
                        <Typography variant='body2'>{report.toUserId.name}</Typography>
                      </Box>
                    </TableCell>

                    {/* Reason */}
                    <TableCell>
                      <Chip size='small' label={report.reportReason} color='error' variant='tonal' />
                    </TableCell>

                    {/* Status */}
                    <TableCell>
                      <Chip size='small' label={getStatusLabel(report.status)} color={getStatusColor(report.status)} />
                    </TableCell>

                    {/* Date */}
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                        {formatDate(report.createdAt)}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {activeTab === 0 && (!reportedUsers || reportedUsers.length === 0) && (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography>No reported users found.</Typography>
          </Box>
        )}

        {activeTab === 1 && blockedUsers && blockedUsers.length > 0 && (
          <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>User</TableCell>
                  <TableCell>Username</TableCell>
                  <TableCell>Block Reason</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {blockedUsers.map(user => (
                  <TableRow key={user._id}>
                    {/* User Info */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={2}>
                        <Avatar src={getFullImageUrl(user.image)} alt={user.name} />
                        <Box>
                          <Typography fontWeight={600}>{user.name}</Typography>
                          <Box display='flex' alignItems='center' gap={1}>
                            <Typography variant='body2'>{user.countryFlagImage}</Typography>
                            <Chip
                              size='small'
                              label={user.gender}
                              color={user.gender?.toLowerCase() === 'male' ? 'primary' : 'error'}
                              variant='tonal'
                            />
                          </Box>
                        </Box>
                      </Box>
                    </TableCell>

                    {/* Username */}
                    <TableCell>
                      <Typography variant='body2' color='text.secondary'>
                        @{user.userName}
                      </Typography>
                    </TableCell>

                    {/* Block Reason */}
                    <TableCell>
                      <Chip size='small' label={user.blockReason || 'Policy Violation'} color='error' variant='tonal' />
                    </TableCell>

                    {/* Status */}
                    <TableCell>
                      <Chip size='small' label='Blocked' color='error' />
                    </TableCell>

                    {/* Date */}
                    <TableCell>
                      <Typography variant='caption' color='text.secondary'>
                        {formatDate(user.blockedAt || user.updatedAt)}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {activeTab === 1 && (!blockedUsers || blockedUsers.length === 0) && (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography>No blocked users found.</Typography>
          </Box>
        )}
      </CardContent>
    </Card>
  )
}

export default BlockedUsers
