'use client'

import { useEffect, useState } from 'react'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MU Imports
import { Typography } from '@mui/material'
import Alert from '@mui/material/Alert'
import AlertTitle from '@mui/material/AlertTitle'
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'

import ActivityOverview from '@/views/dashboard/ActivityOverview'
import {
  ActivityOverviewSkeleton,
  ErrorCard,
  StatisticsCardSkeleton,
  UserListSkeleton
} from '@/views/dashboard/SkeletonLoaders'
import StatisticsCard from '@/views/dashboard/StatisticsCard'
import TopContributors from '@/views/dashboard/TopContributors'
import RecentUsers from '@/views/dashboard/Transactions'

import {
  clearErrors,
  getDashboardMetrics,
  getGraphStats,
  getRecentUsers,
  getTopContributors,
  getTopPerformanceListeners
} from '@/redux-store/slices/dashboard'

import DateRangePicker from '@/components/common/DateRangePicker'
import TopPerformanceListeners from '@/views/dashboard/TopPerformanceListeners'

const Dashboard = () => {
  const dispatch = useDispatch()
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const {
    reportedUsers,
    blockedUsers,
    topPerformanceListeners,
    topContributors,
    recentUsers,
    topHosts,
    topAgencies,
    error,
    loading,
    graphStats
  } = useSelector(state => state.dashboard)

  const [dateRange, setDateRange] = useState({ startDate: 'All', endDate: 'All' })
  const [dashboardError, setDashboardError] = useState(null)

  const fetchDashboardData = (startDate, endDate) => {
    // Clear any previous error
    setDashboardError(null)
    dispatch(clearErrors())

    // Fetch all dashboard data
    dispatch(getDashboardMetrics({ startDate, endDate }))
      .unwrap()
      .catch(err => {
        setDashboardError('Failed to load dashboard metrics')
      })

    dispatch(getRecentUsers({ startDate, endDate }))
    dispatch(getTopContributors({ startDate, endDate }))
    dispatch(getTopPerformanceListeners({ startDate, endDate }))

    // Fetch graph stats for all types
    dispatch(getGraphStats({ startDate, endDate, type: 'listener' }))
    dispatch(getGraphStats({ startDate, endDate, type: 'user' }))
  }

  useEffect(() => {
    fetchDashboardData(searchParams.get("startDate") || "All", searchParams.get("endDate") || "All")
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dispatch , searchParams])

  const handleDateRangeChange = (startDate, endDate) => {
    if (!(dateRange.endDate === endDate && dateRange.startDate === startDate)) {
      setDateRange({ startDate, endDate })

      const params = new URLSearchParams(searchParams.toString())

            params.set('startDate' , startDate)
            params.set('endDate' , endDate)
            router.replace(`${pathname}?${params.toString()}`, { scroll: false })
    }
  }

  const handleRetry = () => {
    fetchDashboardData(dateRange.startDate, dateRange.endDate)
  }

  // Check if any graph stats have error
  const hasGraphError =
    error?.graphStats?.video || error?.graphStats?.post || error?.graphStats?.user || error?.graphStats?.report

  return (
    <>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 4 }}>
        <Typography variant='h5'>Dashboard</Typography>
        <DateRangePicker
          buttonText={
            searchParams.get('startDate') && searchParams.get('endDate')
              ? `${searchParams.get('startDate')} - ${searchParams.get('endDate')}`
              : 'Date Range'
          }
          buttonStartIcon={<i className='tabler-calendar' />}
          setAction={setDateRange}
          initialStartDate={searchParams.get('startDate') || null}
          initialEndDate={searchParams.get('endDate') || null}
          showClearButton={searchParams.get('startDate') && searchParams.get('endDate')}
          onApply={handleDateRangeChange}
          onClear={() => {
            const params = new URLSearchParams(searchParams.toString())

            params.delete('startDate')
            params.delete('endDate')
            router.replace(`${pathname}?${params.toString()}`, { scroll: false })
          }}
        />
      </Box>

      {dashboardError && (
        <Alert severity='error' sx={{ mb: 6 }}>
          <AlertTitle>Error</AlertTitle>
          {dashboardError} —{' '}
          <strong onClick={handleRetry} style={{ cursor: 'pointer', textDecoration: 'underline' }}>
            Try again
          </strong>
        </Alert>
      )}

      <Grid container spacing={6}>
        <Grid size={{ xs: 12, md: topContributors.length || topPerformanceListeners.length ? 8 : 12 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {loading.metrics ? (
              <StatisticsCardSkeleton />
            ) : error?.metrics ? (
              <ErrorCard message={error.metrics} onRetry={handleRetry} />
            ) : (
              <StatisticsCard />
            )}

            {loading.graphStats.listener.length || loading.graphStats.user.length ? (
              <ActivityOverviewSkeleton />
            ) : hasGraphError ? (
              <ErrorCard message='Failed to load activity data' onRetry={handleRetry} />
            ) : (

              graphStats.listener.length || graphStats.listener.length ? <ActivityOverview /> : ""
            )}
            {loading.recentUsers ? (
              <UserListSkeleton />
            ) : error?.recentUsers ? (
              <ErrorCard message={error.recentUsers} onRetry={handleRetry} />
            ) : (
              <RecentUsers recentUsers={recentUsers} />
            )}
          </Box>
        </Grid>
        <Grid size={{ xs: 12, md: 4 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {/* {loading.topContributors ? (
              <UserListSkeleton />
            ) : error?.topContributors ? (
              <ErrorCard message={error.topContributors} onRetry={handleRetry} />
            ) : (
              <TopContributors topContributors={topContributors} />
            )} */}
            {loading.topContributors ? (
              <UserListSkeleton />
            ) : error?.topContributors ? (
              <ErrorCard message={error.topContributors} onRetry={handleRetry} />
            ) : topContributors.length ? (
              <TopContributors topContributors={topContributors} />
            ) : (
              ''
            )}

           {loading.topPerformanceListeners ? (
              <UserListSkeleton />
            ) : error?.topPerformanceListeners ? (
              <ErrorCard message={error.topPerformanceListeners} onRetry={handleRetry} />
            ) : topPerformanceListeners.length ? (
              <TopPerformanceListeners topPerformanceListeners={topPerformanceListeners} />
            ) : (
              ''
            )}
          </Box>
        </Grid>
      </Grid>
    </>
  )
}

export default Dashboard
