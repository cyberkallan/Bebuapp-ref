'use client'

import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import CardActions from '@mui/material/CardActions'
import Skeleton from '@mui/material/Skeleton'
import Box from '@mui/material/Box'
import Divider from '@mui/material/Divider'

const VideoCardSkeleton = () => {
  return (
    <Card sx={{ borderRadius: '12px', overflow: 'hidden' }}>
      <CardHeader
        avatar={<Skeleton animation='wave' variant='circular' width={40} height={40} />}
        action={<Skeleton animation='wave' variant='circular' width={24} height={24} />}
        title={<Skeleton animation='wave' height={20} width='60%' style={{ marginBottom: 6 }} />}
        subheader={<Skeleton animation='wave' height={14} width='40%' />}
      />
      <Skeleton animation='wave' variant='rectangular' height={280} />
      <CardContent>
        <Skeleton animation='wave' height={14} style={{ marginBottom: 8 }} />
        <Skeleton animation='wave' height={14} width='80%' />
        <Box sx={{ mt: 2, display: 'flex', gap: 1 }}>
          <Skeleton animation='wave' height={24} width={60} />
          <Skeleton animation='wave' height={24} width={60} />
          <Skeleton animation='wave' height={24} width={60} />
        </Box>
      </CardContent>
      <Divider />
      <CardActions>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <Skeleton animation='wave' height={24} width={60} />
            <Skeleton animation='wave' height={24} width={60} />
          </Box>
          <Skeleton animation='wave' height={24} width={80} />
        </Box>
      </CardActions>
    </Card>
  )
}

export default VideoCardSkeleton
