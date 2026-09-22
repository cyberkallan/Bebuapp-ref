// MUI Imports
import Grid from '@mui/material/Grid'

// Component Imports
import AboutOverview from './AboutOverview'
import HistoryTables from './HistoryTables'

const ProfileTab = ({ data }) => {
  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12, md: 5, lg: 4 }}>
        <AboutOverview data={data} />
      </Grid>
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
    </Grid>
  )
}

export default ProfileTab
