import { useMemo } from 'react'

// MUI Imports
import Grid from '@mui/material/Grid'

// Component Imports
import { useSelector } from 'react-redux'

import HorizontalWithSubtitle from '@components/card-statistics/HorizontalWithSubtitle'

const UserListCards = ({ states, total, userCount, personType = 'user' }) => {
  // Get current user type
  const { type, data: reduxData } = useSelector(state => state.userReducer)

  // Vars
  const cardData = useMemo(() => {
    // Default data for regular and fake users
    if (type !== 3) {
      return [
        {
          title: `Total ${personType}s`,
          stats: userCount?.activeUsers || 0,
          avatarIcon: 'tabler-user-check',
          avatarColor: 'success',
          trend: 'negative',

          // trendNumber: '14%',
          subtitle: 'Last week analytics'
        },
        {
          title: 'Males',
          stats: userCount?.maleUsers || 0,
          avatarIcon: 'tabler-user',
          avatarColor: 'primary',
          trend: 'positive',

          // trendNumber: '29%',
          subtitle: 'Total User'
        },
        {
          title: 'Females',
          stats: userCount?.femaleUsers || 0,
          avatarIcon: 'tabler-user',
          avatarColor: 'error',
          trend: 'positive',

          // trendNumber: '18%',
          subtitle: 'Last week analytics'
        }

        // {
        //   title: `VIP ${personType}s`,
        //   stats: userCount?.vipUsers || 0,
        //   avatarIcon: 'tabler-users',
        //   avatarColor: 'warning',
        //   trend: 'positive',

        //   // trendNumber: '42%',
        //   subtitle: 'Last week analytics'
        // }
      ]
    } else {
      // Data for live users
      return [
        {
          title: 'Total Live Users',
          stats: reduxData?.totalLiveUsers || 0,
          avatarIcon: 'tabler-video',
          avatarColor: 'success',
          trend: 'positive',

          // trendNumber: '24%',
          subtitle: 'Live streaming users'
        },
        {
          title: 'Video Live',
          stats: reduxData?.totalVideoLive || 0,
          avatarIcon: 'tabler-device-tv',
          avatarColor: 'primary',
          trend: 'positive',

          // trendNumber: '18%',
          subtitle: 'Video streams'
        },
        {
          title: 'Audio Live',
          stats: reduxData?.totalAudioLive || 0,
          avatarIcon: 'tabler-microphone',
          avatarColor: 'info',
          trend: 'negative',

          // trendNumber: '12%',
          subtitle: 'Audio rooms'
        },
        {
          title: 'PK Battle',
          stats: reduxData?.totalPkBattle || 0,
          avatarIcon: 'tabler-swords',
          avatarColor: 'warning',
          trend: 'positive',

          // trendNumber: '30%',
          subtitle: 'Battle rooms'
        }
      ]
    }
  }, [userCount, type, reduxData, personType])

  return (
    <Grid container spacing={6}>
      {cardData.map((item, i) => (
        <Grid key={i} size={{ xs: 12, sm: 6, md: 4 }}>
          <HorizontalWithSubtitle {...item} />
        </Grid>
      ))}
    </Grid>
  )
}

export default UserListCards
