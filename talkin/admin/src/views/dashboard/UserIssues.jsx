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
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'

import { getFullImageUrl } from '@/utils/commonfunctions'

const UserIssues = () => {
  const [tab, setTab] = useState('reported')
  const { reportedUsers, blockedUsers } = useSelector(state => state.dashboard)

  const handleTabChange = (event, newValue) => {
    setTab(newValue)
  }

  const renderReportedUsers = () =>
    reportedUsers.map((report, index) => (
      <Box key={report._id} className='flex items-center mb-6 last:mb-0'>
        <Avatar src={getFullImageUrl(report.userId.image)} alt={report.userId.name} className='me-3' />
        <Box className='flex flex-col flex-grow'>
          <Box className='flex items-center justify-between mb-0.5'>
            <Typography className='font-medium'>{report.userId.name}</Typography>
            <Typography variant='caption' className='text-textSecondary'>
              {new Date(report.createdAt).toLocaleDateString()}
            </Typography>
          </Box>
          <Box className='flex items-center justify-between'>
            <Typography variant='caption' className='text-textSecondary'>
              {report.userId.userName}
            </Typography>
            <Box className='flex items-center gap-2'>
              <Typography variant='caption'>{report.userId.countryFlagImage}</Typography>
              <Chip size='small' label={report.reportReason} color='error' />
            </Box>
          </Box>
          <Box className='flex items-center mt-2'>
            <Typography variant='caption' className='text-textSecondary'>
              Reported: <span className='font-medium'>{report.toUserId.name}</span> ({report.toUserId.userName})
            </Typography>
          </Box>
        </Box>
      </Box>
    ))

  const renderBlockedUsers = () =>
    blockedUsers.map((user, index) => (
      <Box key={user._id} className='flex items-center mb-6 last:mb-0'>
        <Avatar src={getFullImageUrl(user.image)} alt={user.name} className='me-3' />
        <Box className='flex flex-col flex-grow'>
          <Box className='flex items-center justify-between mb-0.5'>
            <Typography className='font-medium'>{user.name}</Typography>
            <Typography variant='caption' className='text-textSecondary'>
              {new Date(user.createdAt).toLocaleDateString()}
            </Typography>
          </Box>
          <Box className='flex items-center justify-between'>
            <Typography variant='caption' className='text-textSecondary'>
              {user.userName}
            </Typography>
            <Box className='flex items-center gap-2'>
              <Typography variant='caption'>{user.countryFlagImage}</Typography>
              <Chip size='small' label='Blocked' color='error' />
            </Box>
          </Box>
        </Box>
      </Box>
    ))

  return (
    <Card>
      <CardHeader
        title='User Issues'
        titleTypographyProps={{ sx: { lineHeight: '2rem !important', letterSpacing: '0.15px !important' } }}
      />
      <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
        <Tabs value={tab} onChange={handleTabChange} aria-label='user issues tabs'>
          <Tab
            value='reported'
            label={`Reported Users (${reportedUsers.length})`}
            id='reported-tab'
            aria-controls='reported-tabpanel'
          />
          <Tab
            value='blocked'
            label={`Blocked Users (${blockedUsers.length})`}
            id='blocked-tab'
            aria-controls='blocked-tabpanel'
          />
        </Tabs>
      </Box>
      <CardContent>{tab === 'reported' ? renderReportedUsers() : renderBlockedUsers()}</CardContent>
    </Card>
  )
}

export default UserIssues
