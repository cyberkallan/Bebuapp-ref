'use client'

// React Imports
import { useEffect, useState } from 'react'

// Next Imports
import { usePathname, useRouter, useSearchParams } from 'next/navigation'

// MUI Imports

import { CardContent, CircularProgress, Divider, MenuItem } from '@mui/material'

import { useInView } from 'react-intersection-observer'

import { TabContext, TabPanel } from '@mui/lab'
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import Grid from '@mui/material/Grid'
import Tab from '@mui/material/Tab'
import Typography from '@mui/material/Typography'

// Redux Imports
import { useDispatch, useSelector } from 'react-redux'

// Style Imports
// import { fetchCallHistoryListener, fetchCoinHistoryListener, resetHistoryState } from '@/redux-store/slices/user'
import {
  fetchCallHistoryListener,
  fetchCoinHistoryListener,
  resetHistoryState,
  setDateRange
} from '@/redux-store/slices/listener'

// Format helpers
import CustomTextField from '@/@core/components/mui/TextField'
import DateRangePicker from '@/components/common/DateRangePicker'
import TablePaginationComponent from '@/components/TablePaginationComponent'
import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'
import LiveStreamTab from '@/views/listener/LiveStreamTab'

import { TransactionItem } from '@/views/listener/TransactionItem'

import CustomTabList from '@/@core/components/mui/TabList'

const HistoryTables = () => {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const dispatch = useDispatch()
  const { ref, inView } = useInView()
  const { defaultCurrency } = useSelector(state => state.currency)

  // Get the current state from Redux
  const { userDetails, startDate, endDate, history, pageSize, page } = useSelector(state => state.listener)

  // const {history } = useSelector(state => state.userReducer)
  const userId = searchParams.get('userId')

  // Get the active tab from URL or default to 'coin'
  const historyTabParam = searchParams.get('tab') || 'coin'

  // Local state
  const [activeTab, setActiveTab] = useState(historyTabParam)

  // Handle tab change
  const handleTabChange = (event, newValue) => {
    const params = new URLSearchParams(searchParams.toString())

    params.set('tab', newValue)
    params.delete('page')
    router.replace(`?${params.toString()}`, { scroll: false })
    setActiveTab(newValue)
    dispatch(resetHistoryState())
  }

  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'
  const urlPage = searchParams.get('page') || 1
  const urlPageSize = searchParams.get('pageSize') || 10

  // Effect to load data when tab changes or user changes
  useEffect(() => {
    if (userId) {
      loadHistoryData()
    }
  }, [activeTab, urlPage, urlPageSize, urlStartDate, urlEndDate])

  // Effect to sync URL with state when tab changes externally
  useEffect(() => {
    if (historyTabParam !== activeTab) {
      setActiveTab(historyTabParam)
    }
  }, [historyTabParam])

  // Function to load data based on current tab
  const loadHistoryData = () => {
    if (!userId) return

    const params = {
      userId: userId,
      start: +(searchParams.get('page') || 1), // API uses 1-based indexing
      limit: +(searchParams.get('pageSize') || 10),
      startDate: searchParams.get('startDate') || 'All',
      endDate: searchParams.get('endDate') || 'All'
    }

    console.log('params-->', params)

    // Dispatch appropriate action based on active tab

    if (activeTab === 'coin') {
      dispatch(fetchCoinHistoryListener(params))
    } else if (activeTab === 'call') {
      dispatch(fetchCallHistoryListener(params))
    }

    // else if (activeTab === 'plan') {
    //   dispatch(fetchPurchaseHistory(params))
    // }
  }

  const typeWiseStats = history.typeWiseStats || []

  const getTransactionTypeDistribution = () => {
    const getTransactionTypeName = type => {
      switch (type) {
        case TRANSACTION_TYPES.PRIVATE_AUDIO_CALL:
          return 'Private Audio Call'
        case TRANSACTION_TYPES.RANDOM_AUDIO_CALL:
          return 'Random Audio Call'
        case TRANSACTION_TYPES.RANDOM_VIDEO_CALL:
          return 'Random Video Call'
        case TRANSACTION_TYPES.PRIVATE_VIDEO_CALL:
          return 'Private Video Call'
        case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
          return 'Coin Plan Purchase'
        case TRANSACTION_TYPES.LOGIN_BONUS:
          return 'Login Bonus'

        default:
          return 'Other'
      }
    }

    // Helper function to get transaction type icon
    const getTransactionTypeIcon = type => {
      switch (type) {
        case TRANSACTION_TYPES.PRIVATE_VIDEO_CALL:
          return 'tabler-video'
        case TRANSACTION_TYPES.RANDOM_VIDEO_CALL:
          return 'tabler-video'
        case TRANSACTION_TYPES.RANDOM_AUDIO_CALL:
          return 'tabler-microphone'
        case TRANSACTION_TYPES.PRIVATE_AUDIO_CALL:
          return 'tabler-microphone'
        case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
          return 'tabler-coin'

        case TRANSACTION_TYPES.LOGIN_BONUS:
          return 'tabler-login'

        default:
          return 'tabler-coin'
      }
    }

    // Helper function to get transaction type color
    const getTransactionTypeColor = type => {
      switch (type) {
        case TRANSACTION_TYPES.PRIVATE_VIDEO_CALL:
          return 'error'
        case TRANSACTION_TYPES.RANDOM_VIDEO_CALL:
          return 'warning'
        case TRANSACTION_TYPES.RANDOM_AUDIO_CALL:
          return 'error'
        case TRANSACTION_TYPES.PRIVATE_AUDIO_CALL:
          return 'success'
        case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
          return 'primary'
        case TRANSACTION_TYPES.LOGIN_BONUS:
          return 'secondary'

        default:
          return 'primary'
      }
    }

    if (!typeWiseStats || typeWiseStats.length === 0) return null

    // Calculate totals
    const totalCounts = typeWiseStats.reduce((sum, stat) => sum + stat.count, 0)
    const totalCoins = typeWiseStats.reduce((sum, stat) => sum + stat.totalCoin, 0)

    // Sort by totalCoin in descending order
    const sortedStats = [...typeWiseStats].sort((a, b) => b.totalCoin - a.totalCoin)

    return (
      <Card variant='outlined' sx={{ m: 3, borderRadius: 2, overflow: 'hidden' }}>
        <Box
          sx={{
            p: 3,
            background: theme => `linear-gradient(45deg, ${theme.palette.primary.light}, ${theme.palette.primary.main})`
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <Box
              sx={{
                width: 40,
                height: 40,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: '50%',
                backgroundColor: 'rgba(255, 255, 255, 0.2)',
                mr: 2,
                backdropFilter: 'blur(8px)'
              }}
            >
              <i className='tabler-chart-pie' style={{ fontSize: '1.5rem', color: 'white' }}></i>
            </Box>
            <Typography variant='h6' sx={{ color: 'white', fontWeight: 600 }}>
              Transaction Type Distribution
            </Typography>
          </Box>
        </Box>

        <CardContent sx={{ p: 3 }}>
          <Grid container spacing={3}>
            {sortedStats.map(stat => {
              const type = parseInt(stat.type)
              const typeName = getTransactionTypeName(type)
              const icon = getTransactionTypeIcon(type)
              const color = getTransactionTypeColor(type)

              return (
                <Grid item size={12} sm={6} md={4} lg={3} key={type}>
                  <Card
                    variant='outlined'
                    sx={{
                      borderRadius: 2,
                      height: '100%',
                      position: 'relative',
                      overflow: 'hidden',
                      transition: 'transform 0.2s, box-shadow 0.2s',
                      '&:hover': {
                        transform: 'translateY(-4px)'
                      }
                    }}
                  >
                    <Box
                      sx={{
                        position: 'absolute',
                        top: 0,
                        right: 0,
                        width: '40%',
                        height: '100%',
                        bgcolor: `${color}.lightest`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        opacity: 0.7
                      }}
                    >
                      <i
                        className={icon}
                        style={{ fontSize: '3rem', color: `var(--mui-palette-${color}-main)`, opacity: 0.3 }}
                      ></i>
                    </Box>

                    <CardContent sx={{ position: 'relative', zIndex: 1, p: 3 }}>
                      <Box sx={{ mb: 2, display: 'flex', alignItems: 'center' }}>
                        <Box
                          sx={{
                            width: 36,
                            height: 36,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            borderRadius: '50%',
                            bgcolor: `${color}.main`,
                            mr: 1.5
                          }}
                        >
                          <i className={icon} style={{ fontSize: '1.2rem', color: 'white' }}></i>
                        </Box>
                        <Typography
                          variant='subtitle1'
                          fontWeight={600}
                          color={`${color}.main`}
                          sx={{
                            textShadow: '0px 0px 1px rgba(0,0,0,0.05)',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap'
                          }}
                        >
                          {typeName}
                        </Typography>
                      </Box>

                      <Box sx={{ mt: 3 }}>
                        <Typography variant='caption' color='text.secondary' fontWeight={500}>
                          TRANSACTIONS
                        </Typography>
                        <Typography variant='h4' fontWeight={700} sx={{ mt: 0.5 }}>
                          {stat.count}
                        </Typography>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              )
            })}
          </Grid>
        </CardContent>
      </Card>
    )
  }

  const updateUrlPagination = (page, pageSize) => {
    const params = new URLSearchParams(searchParams.toString())

    if (page !== 1) {
      params.set('page', page.toString())
    } else {
      params.delete('page')
    }

    if (pageSize !== 10) {
      params.set('pageSize', pageSize.toString())
    } else {
      params.delete('pageSize')
    }

    router.replace(`${pathname}?${params.toString()}`, { scroll: false })
  }

  // Handle pagination

  const handlePageChange = newPage => {
    updateUrlPagination(newPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
  }

  // Render history table based on current tab
  const renderHistoryTable = () => {
    if (!history?.data?.length) {
      return (
        <Box className='flex justify-center items-center py-10'>
          <Typography>No history data found.</Typography>
        </Box>
      )
    }

    return (
      <>
        {/* <Table className={tableStyles.table}> */}
        {activeTab === 'coin' ? (
          <>
            {!history.initialLoading && history.data.length > 0 && getTransactionTypeDistribution()}
            <Box padding={3}>
              {history.data.map((transaction, index) => (
                <TransactionItem key={`${transaction._id}-${index}`} transaction={transaction} transactionType={null} />
              ))}

              {/* Loading more indicator */}
              {history.loading && (
                <Box display='flex' justifyContent='center' my={2}>
                  <CircularProgress size={30} />
                </Box>
              )}

              {/* Intersection observer target for infinite scroll */}
              {history.hasMore && <div ref={ref} style={{ height: '20px' }} />}

              {/* End of list message */}
              {!history.hasMore && (
                <Box textAlign='center' my={2}>
                  <Typography variant='body2' color='text.secondary'>
                    No more transactions
                  </Typography>
                </Box>
              )}
            </Box>
          </>
        ) : (
          ''
        )}
        {activeTab === 'call' ? (
          <div className='p-4'>
            <LiveStreamTab history={history} />
          </div>
        ) : (
          ''
        )}
        {/* </Table> */}
        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={history?.total}
          onPageChange={handlePageChange}
        />
      </>
    )
  }

  useEffect(() => {
    if (!defaultCurrency) {
      dispatch(fetchDefaultCurrencies())
    }
  }, [])

  const handleRowsPerPageChange = e => {
    const newPageSize = parseInt(e.target.value, 10)

    updateUrlPagination(1, newPageSize)
  }

  return (
    <Card>
      <CardHeader
        title='Listener History'
        action={
          <Box className='flex items-center gap-2'>
            <CustomTextField
              select
              value={searchParams.get('pageSize') || 10}
              onChange={handleRowsPerPageChange}
              className='max-sm:is-full sm:is-[70px]'
            >
              <MenuItem value='2'>2</MenuItem>
              <MenuItem value='10'>10</MenuItem>
              <MenuItem value='25'>25</MenuItem>
              <MenuItem value='50'>50</MenuItem>
            </CustomTextField>
            <DateRangePicker
              buttonText={
                searchParams.get('startDate') && searchParams.get('endDate')
                  ? `${searchParams.get('startDate')} - ${searchParams.get('endDate')}`
                  : 'Date Range'
              }
              buttonStartIcon={<i className='tabler-calendar' />}
              setAction={setDateRange}
              initialStartDate={searchParams.get('startDate') ? new Date(startDate) : null}
              initialEndDate={searchParams.get('endDate') ? new Date(endDate) : null}
              showClearButton={searchParams.get('startDate') && searchParams.get('endDate')}
              onClear={() => {
                if (searchParams.get('startDate') && searchParams.get('endDate')) {
                  dispatch(setDateRange({ startDate: 'All', endDate: 'All' }))
                  const params = new URLSearchParams(searchParams.toString())

                  params.delete('startDate')
                  params.delete('endDate')
                  params.get('page') && params.set('page', '1')
                  router.replace(`${pathname}?${params.toString()}`, { scroll: false })
                }
              }}
              onApply={(newStartDate, newEndDate) => {
                const params = new URLSearchParams(searchParams.toString())

                if (newStartDate !== 'All') params.set('startDate', newStartDate)
                else params.delete('startDate')
                if (newEndDate !== 'All') params.set('endDate', newEndDate)
                else params.delete('endDate')
                params.get('page') && params.set('page', '1')
                router.replace(`${pathname}?${params.toString()}`, { scroll: false })
                dispatch(setDateRange({ startDate: newStartDate, endDate: newEndDate }))
              }}
            />
          </Box>
        }
      />
      <Divider className='mb-5' />
      <TabContext value={activeTab}>
        <Grid container>
          <Grid item size={12}>
            <CustomTabList onChange={handleTabChange} variant='scrollable' pill='true'>
              <Tab
                value='coin'
                label='Coin History'
                icon={<i className='tabler-coin' />}
                iconPosition='start'
                className='ms-4'
              />
              <Tab value='call' label='Call History' icon={<i className='tabler-phone' />} iconPosition='start' />
            </CustomTabList>
          </Grid>
          <Grid item size={12}>
            <TabPanel value={activeTab} className='p-0'>
              {history?.loading ? (
                <Box className='flex justify-center items-center py-10 h-96'>
                  <CircularProgress />
                </Box>
              ) : (
                <div className='mt-4 overflow-x-auto'>{renderHistoryTable()}</div>
              )}
            </TabPanel>
          </Grid>
        </Grid>
      </TabContext>
    </Card>
  )
}

export default HistoryTables
