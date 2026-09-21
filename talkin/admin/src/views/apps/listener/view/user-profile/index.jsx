'use client'

// React Imports
import { useState } from 'react'

// MUI Imports
import Grid from '@mui/material/Grid'

// Component Imports
import Profile from './profile'
import UserProfileHeader from './UserProfileHeader'

const UserProfile = ({ tabContentList, data }) => {
  // const { userDetails } = useSelector(state => state.userReducer)
  const [activeTab, setActiveTab] = useState('profile')

  // const handleChange = (event, value) => {
  //   setActiveTab(value)
  // }

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <UserProfileHeader data={data} />
      </Grid>
      {activeTab === undefined ? null : (
        <Grid size={{ xs: 12 }} className='flex flex-col gap-6'>
          <Profile />
        </Grid>
      )}
    </Grid>
  )
}

export default UserProfile
