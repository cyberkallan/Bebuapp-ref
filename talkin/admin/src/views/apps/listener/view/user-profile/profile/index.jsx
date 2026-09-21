import { useState } from 'react'

// MUI Imports
import Grid from '@mui/material/Grid'

// Component Imports

import AboutOverview from './AboutOverview'
import HistoryTables from './HistoryTables'

const ProfileTab = ({ data }) => {
  const [userDetails, setUserDetails] = useState(
    localStorage.getItem('selectedListener') ? JSON.parse(localStorage.getItem('selectedListener')) : null
  )

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12, md: 6, lg: userDetails?.isFake ? 12 : 4 }}>
        <AboutOverview data={data} />
      </Grid>
      {!userDetails?.isFake && (
        <>
          <Grid size={{ xs: 12, md: 7, lg: 8 }}>
            <Grid container spacing={6}>
              {/* <Grid size={{ xs: 12 }}>
            <ActivityTimeline />
          </Grid> */}
              {/* <ConnectionsTeams connections={data?.connections} teamsTech={data?.teamsTech} /> */}
              <Grid size={{ xs: 12 }}>
                <HistoryTables />
              </Grid>
            </Grid>
          </Grid>
        </>
      )}
    </Grid>
  )
}

export default ProfileTab
