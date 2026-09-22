'use client'

// React Imports
import { useSelector } from 'react-redux'

// MUI Imports
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'

const CongratulationsJohn = () => {
  const { metrics } = useSelector(state => state.dashboard)

  return (
    <Card className='relative overflow-visible bg-primary'>
      <CardContent>
        <Typography variant='h5' className='text-white font-medium mbe-2'>
          Platform Overview
        </Typography>
        <Typography className='text-white/80 mbe-6'>
          Here&apos;s what&apos;s happening on your platform today!
        </Typography>
        <div className='flex flex-col gap-4'>
          <div>
            <Typography variant='h3' className='text-white font-medium'>
              {metrics.totalUsers}
            </Typography>
            <Typography className='text-white/80'>Total Users</Typography>
          </div>
          <div className='flex gap-4'>
            <div>
              <Typography variant='h6' className='text-white font-medium'>
                {metrics.totalPosts}
              </Typography>
              <Typography className='text-white/80'>Posts</Typography>
            </div>
            <div>
              <Typography variant='h6' className='text-white font-medium'>
                {metrics.totalVideos}
              </Typography>
              <Typography className='text-white/80'>Videos</Typography>
            </div>
            <div>
              <Typography variant='h6' className='text-white font-medium'>
                {metrics.totalVipUsers}
              </Typography>
              <Typography className='text-white/80'>VIP Users</Typography>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export default CongratulationsJohn
