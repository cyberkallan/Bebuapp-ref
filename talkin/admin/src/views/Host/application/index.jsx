'use client'
import { useEffect, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { useDispatch } from 'react-redux'

import { TabContext, TabPanel } from '@mui/lab'
import { Tab, Typography } from '@mui/material'
import Grid from '@mui/material/Grid'

import CustomTabList from '@/@core/components/mui/TabList'
import { APPLICATION_STATUS, resetState, setStatus } from '@/redux-store/slices/listenerRequest'
import HostApplicationTable from './ListenerRequestTable'

const ListenerRequest = () => {
  const router = useRouter()
  const searchParams = useSearchParams()
  const dispatch = useDispatch()
  const pathname = usePathname()

  const tabFromQuery = searchParams.get('tab')

  const tabToStatusMap = {
    pending: APPLICATION_STATUS.PENDING,
    approved: APPLICATION_STATUS.APPROVED,
    rejected: APPLICATION_STATUS.REJECTED
  }

  const [activeTab, setActiveTab] = useState(
    tabFromQuery && Object.keys(tabToStatusMap).includes(tabFromQuery) ? tabFromQuery : 'pending'
  )

  useEffect(() => {
    dispatch(resetState())

    const currentTab = tabFromQuery && Object.keys(tabToStatusMap).includes(tabFromQuery) ? tabFromQuery : 'pending'

    setActiveTab(currentTab)

    dispatch(setStatus(tabToStatusMap[currentTab]))

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tabFromQuery])

  const handleChange = (event, value) => {
    if (value === activeTab) return
    const newSearchParams = new URLSearchParams(searchParams.toString())

    newSearchParams.set('tab', value)
    newSearchParams.delete('page')

    router.replace(`${pathname}?${newSearchParams.toString()}`)
  }

  return (
    <>
      <Typography variant='h5' sx={{ mb: 4 }}>
        Listener Request
      </Typography>
      <TabContext value={activeTab}>
        <Grid container spacing={6}>
          <Grid item xs={12}>
            <CustomTabList onChange={handleChange} variant='scrollable' pill='true'>
              <Tab icon={<i className='tabler-clock' />} value='pending' label='Pending' iconPosition='start' />
              <Tab
                icon={<i className='tabler-circle-check' />}
                value='approved'
                label='Approved'
                iconPosition='start'
              />
              <Tab icon={<i className='tabler-circle-x' />} value='rejected' label='Rejected' iconPosition='start' />
            </CustomTabList>
          </Grid>
          <Grid item size={12}>
            <TabPanel value={activeTab} className='p-0'>
              <HostApplicationTable />
            </TabPanel>
          </Grid>
        </Grid>
      </TabContext>
    </>
  )
}

export default ListenerRequest
