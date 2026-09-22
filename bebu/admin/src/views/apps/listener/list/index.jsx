'use client'
import { useCallback, useEffect, useRef, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { useDispatch } from 'react-redux'

// MUI Imports
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

import { TabContext, TabPanel } from '@mui/lab'
import { Tab } from '@mui/material'

// Component Imports
import ListenerListTable from './ListenerListTable'

// Actions
import CustomTabList from '@/@core/components/mui/TabList'

import { fetchListeners } from '@/redux-store/slices/listener'

const ListenerList = () => {
  const dispatch = useDispatch()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const fetchInProgress = useRef(false)
  const lastFetchParams = useRef(null)
  const tabChangeInProgress = useRef(false)
  const isInitialLoad = useRef(true)

  const tabFromQuery = searchParams.get('tab')
  const [activeTab, setActiveTab] = useState(tabFromQuery ? tabFromQuery : 'real')

  // Get values from URL
  const urlPage = parseInt(searchParams.get('page') || '1')
  const urlPageSize = parseInt(searchParams.get('pageSize') || '10')
  const urlSearch = searchParams.get('search') || ''
  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'
  const urlIsFake = searchParams.get('tab') === 'fake' ? true : false

  const getListeners = useCallback(
    params => {
      if (fetchInProgress.current) return
      fetchInProgress.current = true
      dispatch(fetchListeners(params)).finally(() => {
        fetchInProgress.current = false
        tabChangeInProgress.current = false
      })
    },
    [dispatch]
  )

  // Main useEffect for API calls - only depends on critical params
  useEffect(() => {
    // Skip if tab change is in progress and dates are being reset
    if (tabChangeInProgress.current) return

    const currentUrlPage = parseInt(searchParams.get('page') || '1')
    const currentUrlPageSize = parseInt(searchParams.get('pageSize') || '10')
    const currentUrlStartDate = searchParams.get('startDate') || 'All'
    const currentUrlEndDate = searchParams.get('endDate') || 'All'
    const currentUrlIsFake = activeTab === 'fake' ? 'true' : 'false'

    const currentParams = {
      page: currentUrlPage,
      limit: currentUrlPageSize,
      startDate: currentUrlStartDate,
      endDate: currentUrlEndDate,
      isFake: currentUrlIsFake
    }

    // Only make API call if params actually changed
    const paramsChanged =
      !lastFetchParams.current || JSON.stringify(lastFetchParams.current) !== JSON.stringify(currentParams)

    if (paramsChanged) {
      lastFetchParams.current = currentParams
      getListeners(currentParams)
    }
  }, [activeTab, urlPage, urlPageSize, urlStartDate, urlEndDate])

  const handleChange = (event, value) => {
    if (value === activeTab) return

    // Set flag to prevent duplicate API calls during tab change
    tabChangeInProgress.current = true

    // Create new search params with reset dates
    const newSearchParams = new URLSearchParams(searchParams.toString())

    newSearchParams.set('tab', value)
    newSearchParams.delete('startDate')
    newSearchParams.delete('endDate')
    newSearchParams.set('page', '1') // Reset to first page when changing tabs

    // Update URL first
    router.replace(`${pathname}?${newSearchParams.toString()}`)

    // Update active tab
    setActiveTab(value)

    // Make immediate API call with reset dates
    const resetParams = {
      page: 1,
      limit: parseInt(searchParams.get('pageSize') || '10'),
      startDate: 'All',
      endDate: 'All',
      isFake: value === 'fake' ? 'true' : 'false'
    }

    lastFetchParams.current = resetParams
    getListeners(resetParams)
  }

  return (
    <>
      <Typography variant='h5' sx={{ mb: 4 }}>
        Listener Management
      </Typography>
      <TabContext value={activeTab}>
        <Grid container spacing={6}>
          <Grid item xs={12}>
            <CustomTabList onChange={handleChange} variant='scrollable' pill='true'>
              <Tab icon={<i className='tabler-user-star' />} value='real' label='Real Listener' iconPosition='start' />
              <Tab
                icon={<i className='tabler-user-cancel' />}
                value='fake'
                label='Fake Listener'
                iconPosition='start'
              />
            </CustomTabList>
          </Grid>
          <Grid size={12}>
            <TabPanel value={activeTab} className='p-0'>
              <ListenerListTable />
            </TabPanel>
          </Grid>
        </Grid>
      </TabContext>
    </>
  )
}

export default ListenerList
