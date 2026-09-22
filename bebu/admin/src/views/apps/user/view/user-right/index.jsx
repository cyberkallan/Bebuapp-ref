'use client'

// React Imports
import { useState, useEffect } from 'react'

// MUI Imports
import { useRouter, useSearchParams } from 'next/navigation'

import Tab from '@mui/material/Tab'
import TabContext from '@mui/lab/TabContext'
import TabPanel from '@mui/lab/TabPanel'
import Grid from '@mui/material/Grid'

// Component Imports
import CustomTabList from '@core/components/mui/TabList'

// Next Imports

const UserRight = ({ tabContentList }) => {
  const router = useRouter()
  const searchParams = useSearchParams()

  // Get tab from URL or default to 'overview'
  const tabParam = searchParams.get('tab') || 'overview'

  // States
  const [activeTab, setActiveTab] = useState(tabParam)

  // Update URL when tab changes
  const handleChange = (event, value) => {
    setActiveTab(value)
    updateUrlParams('tab', value)
  }

  // Helper to update URL params without losing existing ones
  const updateUrlParams = (key, value) => {
    const params = new URLSearchParams(searchParams.toString())

    params.set(key, value)
    router.push(`?${params.toString()}`, { scroll: false })
  }

  // Sync state with URL when URL changes externally
  useEffect(() => {
    if (tabParam !== activeTab) {
      setActiveTab(tabParam)
    }
  }, [tabParam, activeTab])

  return (
    <>
      <TabContext value={activeTab}>
        <Grid container spacing={6}>
          {/* <Grid size={{ xs: 12 }}> */}
          {/* <CustomTabList onChange={handleChange} variant='scrollable' pill='true'>
              <Tab icon={<i className='tabler-users' />} value='overview' label='Overview' iconPosition='start' />
              {tabContentList.history && (
                <Tab icon={<i className='tabler-history' />} value='history' label='History' iconPosition='start' />
              )}
            </CustomTabList> */}
          {/* </Grid> */}
          <Grid size={{ xs: 12 }}>
            <TabPanel value={activeTab} className='p-0'>
              {tabContentList[activeTab]}
            </TabPanel>
          </Grid>
        </Grid>
      </TabContext>
    </>
  )
}

export default UserRight
