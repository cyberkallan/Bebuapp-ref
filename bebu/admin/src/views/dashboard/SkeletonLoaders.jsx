import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'

import Skeleton from '@/components/shimmer/Skeleton'

// Skeleton for Statistics Cards
export const StatisticsCardSkeleton = () => {
  return (
    <Card>
      <CardContent sx={{ p: 5 }}>
        <Grid container spacing={6}>
          {[1, 2, 3, 4, 5, 6].map(item => (
            <Grid key={item} item size={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Skeleton width={50} height={50} variant='circular' />
                <Box sx={{ width: '100%' }}>
                  <Skeleton width='70%' height={20} sx={{ mb: 1 }} />
                  <Skeleton width='40%' height={24} />
                </Box>
              </Box>
            </Grid>
          ))}
        </Grid>
      </CardContent>
    </Card>
  )
}

// Skeleton for Activity Overview (Chart)
export const ActivityOverviewSkeleton = () => {
  return (
    <Card>
      <CardHeader title={<Skeleton width={200} height={24} />} action={<Skeleton width={100} height={40} />} />
      <CardContent>
        <Skeleton height={300} />
      </CardContent>
    </Card>
  )
}

// Skeleton for Top Contributors, Recent Users, and Top Likers
export const UserListSkeleton = ({ title = true }) => {
  return (
    <Card>
      {title && (
        <CardHeader title={<Skeleton width={160} height={24} />} action={<Skeleton width={80} height={40} />} />
      )}
      <CardContent>
        {[1, 2, 3, 4, 5].map(item => (
          <Box key={item} sx={{ display: 'flex', alignItems: 'center', mb: 3, gap: 2 }}>
            <Skeleton width={40} height={40} variant='circular' />
            <Box sx={{ width: '100%' }}>
              <Skeleton width='60%' height={16} sx={{ mb: 1 }} />
              <Skeleton width='40%' height={14} />
            </Box>
            <Skeleton width={40} height={24} />
          </Box>
        ))}
      </CardContent>
    </Card>
  )
}

// Error display component
export const ErrorCard = ({ message, onRetry }) => {
  return (
    <Card>
      <CardContent sx={{ textAlign: 'center', py: 5 }}>
        <Typography variant='h6' color='error' sx={{ mb: 2 }}>
          {message || 'Failed to load data'}
        </Typography>
        {onRetry && (
          <Typography
            component='button'
            variant='body2'
            onClick={onRetry}
            sx={{
              color: 'primary.main',
              bgcolor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              textDecoration: 'underline',
              p: 0,
              m: 0
            }}
          >
            Retry
          </Typography>
        )}
      </CardContent>
    </Card>
  )
}
