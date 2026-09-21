'use client'

// MUI Imports
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CardHeader from '@mui/material/CardHeader'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'
import { useSelector } from 'react-redux'

// Component Imports
import CustomAvatar from '@core/components/mui/Avatar'

const StatisticsCard = () => {
  const { metrics } = useSelector(state => state.dashboard)

  const data = [
    {
      stats: metrics.totalUsers || 0,
      title: 'Total Users',
      color: 'primary',
      icon: 'tabler-users'
    },
    {
      stats: metrics.totalBlockedUsers || 0,
      title: 'Blocked Users',
      color: 'info',
      icon: 'tabler-crown'
    },
    {
      stats: metrics.totalPendingListeners || 0,
      title: 'Pending Listeners',
      color: 'warning',
      icon: 'tabler-alert-triangle'
    },
    {
      stats: metrics.totalListeners || 0,
      title: 'Total Listeners',
      color: 'secondary',
      icon: 'tabler-ban'
    },
    {
      stats: metrics.totalTalkTopics || 0,
      title: 'Total Talk Topics',
      color: 'primary',
      icon: 'tabler-user-star'
    },
    {
      stats: metrics.totalPendingWithdrawalRecord || 0,
      title: 'Pending Withdrawal',
      color: 'secondary',
      icon: 'tabler-user-off'
    }
  ]

  return (
    <Card>
      <CardHeader
        title='Statistics'
        action={
          <Typography variant='subtitle2' color='text.disabled'>
            Real-time Data
          </Typography>
        }
      />
      <CardContent className='flex justify-between flex-wrap gap-4 md:pbs-10 max-md:pbe-6 max-[1060px]:pbe-[74px] max-[1200px]:pbe-[52px] max-[1320px]:pbe-[74px] max-[1501px]:pbe-[52px]'>
        <Grid container spacing={4} sx={{ inlineSize: '100%' }}>
          {data.map((item, index) => (
            <Grid key={index} size={{ xs: 6, sm: 3 }} className='flex items-center gap-4'>
              <CustomAvatar color={item.color} variant='rounded' size={40} skin='light'>
                <i className={item.icon}></i>
              </CustomAvatar>
              <div className='flex flex-col'>
                <Typography variant='h5'>{item.stats}</Typography>
                <Typography variant='body2' className='text-nowrap'>
                  {item.title}
                </Typography>
              </div>
            </Grid>
          ))}
        </Grid>
      </CardContent>
    </Card>
  )
}

export default StatisticsCard
