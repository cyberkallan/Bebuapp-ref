// ✅ Full implementation of HostList Page - index.jsx
'use client'

import { useEffect } from 'react'

import { useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Grid from '@mui/material/Grid'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import FilterListIcon from '@mui/icons-material/FilterList'

// Component Imports
import HostListTable from './HostListTable'
import UserListCards from '@/views/apps/user/list/UserListCards'

// Redux Imports
import { fetchHosts, setHostPage, setHostDateRange } from '@/redux-store/slices/hostList'
import DateRangePicker from '@/components/common/DateRangePicker'

const HostList = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()

  const { hostList, hostStats, hostPage, hostPageSize, hostSearch, hostType, hostStartDate, hostEndDate } = useSelector(
    state => state.hostList
  )

  const urlPage = parseInt(searchParams.get('page')) || 1
  const urlPageSize = parseInt(searchParams.get('pageSize')) || 10

  useEffect(() => {
    dispatch(
      fetchHosts({
        page: urlPage,
        pageSize: urlPageSize,
        type: hostType,
        searchQuery: hostSearch,
        startDate: hostStartDate,
        endDate: hostEndDate
      })
    )
  }, [dispatch, hostSearch, hostType, hostStartDate, hostEndDate, urlPage, urlPageSize])

  return (
    <Grid container spacing={6}>
      <Grid item xs={12}>
        <Box display='flex' justifyContent='space-between' alignItems='center' mb={4}>
          <Typography variant='h5'>Host Management</Typography>
          <DateRangePicker
            buttonText={
              hostStartDate !== 'All' && hostEndDate !== 'All' ? `${hostStartDate} - ${hostEndDate}` : 'Filter by Date'
            }
            buttonVariant='outlined'
            buttonClassName='shadow-sm'
            buttonStartIcon={<FilterListIcon />}
            onApply={(start, end) => {
              dispatch(setHostDateRange({ startDate: start, endDate: end }))
              dispatch(setHostPage(1))
            }}
            showClearButton={hostStartDate !== 'All' && hostEndDate !== 'All'}
            onClear={() => {
              dispatch(setHostDateRange({ startDate: 'All', endDate: 'All' }))
              dispatch(setHostPage(1))
            }}
          />
        </Box>
        <UserListCards
          states={[]}
          total={hostStats?.totalActiveHosts || 0}
          userCount={{
            activeUsers: hostStats?.totalActiveHosts || 0,
            femaleUsers: hostStats?.totalFemaleHosts || 0,
            vipUsers: hostStats?.totalVIPHosts || 0,
            maleUsers: hostStats?.totalMaleHosts || 0
          }}
          personType='host'
        />
      </Grid>

      <Grid item xs={12}>
        <HostListTable tableData={hostList} />
      </Grid>
    </Grid>
  )
}

export default HostList
