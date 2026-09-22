// MUI Imports
import Grid from '@mui/material/Grid'

// Component Imports
import UserDetails from './UserDetails'
import UserPlan from './UserPlan'

const UserLeftOverview = ({ userDetails }) => {
  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <UserDetails userDetails={userDetails} />
      </Grid>
      {/* <Grid size={{ xs: 12 }}>
        <UserPlan userDetails={userDetails} />
      </Grid> */}
    </Grid>
  )
}

export default UserLeftOverview
