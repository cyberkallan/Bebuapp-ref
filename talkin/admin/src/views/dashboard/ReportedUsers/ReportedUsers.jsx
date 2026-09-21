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

const ReportedUsers = ({ reportedUsers }) => {
  const [showAll, setShowAll] = useState(false)

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

  if (!reportedUsers || reportedUsers.length === 0) {
    return null
  }

  const displayedReportedUsers = showAll ? reportedUsers : reportedUsers.slice(0, 5)

  return (
    <Card>
      <CardHeader title='Reported Users' titleTypographyProps={{ sx: { fontWeight: 600, fontSize: '1.25rem' } }} />
      <CardContent sx={{ p: 0 }}>
        <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Reporter User</TableCell>
                <TableCell>Reported User</TableCell>
                <TableCell>Reason</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Date Joined</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {displayedReportedUsers.length > 0 ? (
                displayedReportedUsers.map(report => (
                  <TableRow key={report._id}>
                    {/* Reporter Info */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={2}>
                        <Avatar src={getFullImageUrl(report.userId.image)} alt={report.userId.name} />
                        <Box>
                          <Typography fontWeight={600} title={report.userId.name}>
                            {report.userId.name.length > 15
                              ? `${report.userId.name.slice(0, 15)}...`
                              : report.userId.name}
                          </Typography>
                          <Typography variant='body2'>{report.userId.userName}</Typography>
                          <Chip
                            size='small'
                            label={report.userId.gender}
                            color={report.userId.gender?.toLowerCase() === 'male' ? 'primary' : 'error'}
                            variant='tonal'
                          />
                        </Box>
                      </Box>
                    </TableCell>

                    {/* Reported User */}
                    <TableCell>
                      <Box display='flex' alignItems='center' gap={1}>
                        <Avatar src={getFullImageUrl(report.toUserId.image)} alt={report.toUserId.name} />
                        <Box>
                          <Typography variant='body2'>{report.toUserId.name}</Typography>
                          <Typography variant='body2'>{report.toUserId.userName}</Typography>
                          <Chip
                            size='small'
                            label={report.toUserId.gender}
                            color={report.toUserId.gender?.toLowerCase() === 'male' ? 'primary' : 'error'}
                            variant='tonal'
                          />
                        </Box>
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
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={5} className='text-center'>
                    No reported users found
                  </TableCell>
                </TableRow>
              )}
              {reportedUsers.length > 5 && !showAll && (
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

export default ReportedUsers
