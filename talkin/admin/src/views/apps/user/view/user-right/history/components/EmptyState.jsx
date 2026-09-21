'use client'

import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'

import CustomAvatar from '@core/components/mui/Avatar'

// Empty State Component
const EmptyState = ({
  title = 'No Transactions Found',
  description = 'There are no transactions in this category.',
  icon = 'tabler-history'
}) => (
  <Box textAlign='center' py={4}>
    <CustomAvatar skin='light' color='primary' sx={{ width: 60, height: 60, mb: 2, mx: 'auto' }}>
      <i className={`${icon} text-xl`} />
    </CustomAvatar>
    <Typography variant='h6'>{title}</Typography>
    <Typography variant='body2' color='text.secondary'>
      {description}
    </Typography>
  </Box>
)

export default EmptyState
