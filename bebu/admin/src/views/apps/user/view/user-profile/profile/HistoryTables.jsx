'use client'

// React Imports
import { useEffect, useRef, useState } from 'react'

// Next Imports
import { usePathname, useRouter, useSearchParams } from 'next/navigation'

// MUI Imports

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
import { CardContent, CircularProgress, Divider, MenuItem, Paper, Stack } from '@mui/material'
import { useInView } from 'react-intersection-observer'

import CustomAvatar from '@/@core/components/mui/Avatar'
import {
  fetchCallHistory,
  fetchPurchaseHistory,
  fetchWalletHistory,
  resetHistoryState,
  setDateRange
} from '@/redux-store/slices/user'

// Format helpers
import CustomTextField from '@/@core/components/mui/TextField'
import DateRangePicker from '@/components/common/DateRangePicker'
import TablePaginationComponent from '@/components/TablePaginationComponent'

import { fetchDefaultCurrencies } from '@/redux-store/slices/currency'

import CustomTabList from '@/@core/components/mui/TabList'
import { TransactionItem } from '../../user-right/history/components'
import LiveStreamTab from '../../user-right/history/components/LiveStreamTab'
import { TRANSACTION_TYPES } from '../../user-right/history/constants'

const HistoryTables = () => {
  const router = useRouter()
  const searchParams = useSearchParams()
  const dispatch = useDispatch()
  const pathname = usePathname()
  const { ref } = useInView()
  const { defaultCurrency } = useSelector(state => state.currency)
  const DateRangeRef = useRef(false)

  const { history, startDate, endDate, page, pageSize } = useSelector(state => state.userReducer)
  const userDetails = localStorage.getItem('selectedUser') ? JSON.parse(localStorage.getItem('selectedUser')) : {}
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
                <Grid item xs={12} sm={6} md={4} lg={3} key={type}>
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

  const historyTabParam = searchParams.get('tab') || 'coin'
  const [activeTab, setActiveTab] = useState(historyTabParam)

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

  // Handle tab change
  const handleTabChange = (event, newValue) => {
    const params = new URLSearchParams(searchParams.toString())

    params.set('tab', newValue)
    params.delete('page')
    router.replace(`?${params.toString()}`, { scroll: false })
    setActiveTab(newValue)
    dispatch(resetHistoryState())
  }

  // Handle pagination
  const handlePageChange = newPage => {
    updateUrlPagination(newPage, searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize)
    console.log('One')
  }

  const urlStartDate = searchParams.get('startDate') || 'All'
  const urlEndDate = searchParams.get('endDate') || 'All'
  const urlPage = searchParams.get('page') || 1
  const urlPageSize = searchParams.get('pageSize') || 10

  // Effect to load data when tab changes or user changes
  useEffect(() => {
    if (userDetails?._id) {
      loadHistoryData()
    }
  }, [activeTab, userDetails?._id, urlPage, urlPageSize, urlStartDate, urlEndDate])

  // Effect to sync URL with state when tab changes externally
  useEffect(() => {
    if (historyTabParam !== activeTab) {
      setActiveTab(historyTabParam)
    }
  }, [historyTabParam])

  useEffect(() => {
    if (!defaultCurrency) {
      dispatch(fetchDefaultCurrencies())
    }
  }, [])

  // Function to load data based on current tab
  const loadHistoryData = () => {
    if (!userDetails?._id) return

    const params = {
      userId: userDetails._id,
      start: +(searchParams.get('page') || 1), // API uses 1-based indexing
      limit: +(searchParams.get('pageSize') || 10),
      startDate: searchParams.get('startDate') || 'All',
      endDate: searchParams.get('endDate') || 'All'
    }

    // Dispatch appropriate action based on active tab
    if (activeTab === 'coin') {
      dispatch(fetchWalletHistory(params))
    } else if (activeTab === 'call') {
      dispatch(fetchCallHistory(params))
    } else if (activeTab === 'plan') {
      dispatch(fetchPurchaseHistory(params))
    }
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
        {activeTab === 'plan' ? (
          <>
            {history.data.map((transaction, index) => {
              return (
                <Paper elevation={0} className='p-4 border rounded-md m-3' key={index}>
                  <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 3 }} className='md:flex-row flex-col'>
                    <Box className='flex items-center justify-between w-full md:w-auto'>
                      <CustomAvatar skin='light' color={'primary'} variant='rounded'>
                        <i className={'tabler-coin'} />
                      </CustomAvatar>
                      {/* show on mobile */}
                      <Box sx={{ textAlign: 'right', display: { xs: 'block', md: 'none' } }}>
                        <Typography
                          variant='body2'
                          sx={{ fontWeight: 600 }}
                          color={transaction.isIncome ? 'success.main' : 'error.main'}
                        >
                          {transaction.isIncome ? '+' : '-'}
                          {transaction.userCoin} Coins
                        </Typography>
                      </Box>
                    </Box>

                    <Box sx={{ flexGrow: 1 }}>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <Box>
                          <Typography variant='subtitle2'>Coin Plan Purchase</Typography>

                          <Box display='flex' gap={2} alignItems='center'>
                            <Typography variant='caption' color='text.secondary'>
                              ID: {transaction.uniqueId} | {transaction?.date}
                            </Typography>
                          </Box>
                        </Box>

                        <Box sx={{ textAlign: 'right', display: { xs: 'none', md: 'block' } }}>
                          <Box>
                            {/* <Chip  label={formatDuration(transaction.duration)} size='small' color='info' sx={{ ml: 'auto' }} /> */}
                          </Box>
                          <Typography variant='body2' sx={{ fontWeight: 600 }} color={'success.main'}>
                            + {transaction.userCoin} Coins
                          </Typography>
                        </Box>
                      </Box>

                      <Box className='transaction-details mt-3'>
                        <Divider sx={{ mb: 2 }} />
                        <Stack
                          direction={{ xs: 'column', sm: 'row' }}
                          mt={2}
                          spacing={2}
                          alignItems={{ xs: 'flex-start', lg: 'center' }}
                        >
                          <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                            <CustomAvatar skin='light' color='primary' size='sm' sx={{ mr: 1.5 }}>
                              <i className='tabler-tag'></i>
                            </CustomAvatar>
                            <Box>
                              <Typography variant='caption' color='text.priary'>
                                Amount
                              </Typography>
                              <Typography variant='body2'>{transaction?.price || '0'}</Typography>
                            </Box>
                          </Box>
                          <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                            <CustomAvatar skin='light' color='primary' size='sm' sx={{ mr: 1.5 }}>
                              <i className='tabler-credit-card-pay'></i>
                            </CustomAvatar>
                            <Box>
                              <Typography variant='caption' color='text.secondary'>
                                Payment Gateway
                              </Typography>
                              <Typography variant='body2'>{transaction?.paymentGateway || '-'}</Typography>
                            </Box>
                          </Box>
                        </Stack>
                      </Box>
                    </Box>
                  </Box>
                </Paper>
              )
            })}
          </>
        ) : (
          ''
        )}
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
        <TablePaginationComponent
          page={searchParams.get('page') ? parseInt(searchParams.get('page'), 10) : page}
          pageSize={searchParams.get('pageSize') ? parseInt(searchParams.get('pageSize'), 10) : pageSize}
          total={history?.total}
          onPageChange={handlePageChange}
        />
      </>
    )
  }

  const handleRowsPerPageChange = e => {
    const newPageSize = parseInt(e.target.value, 10)

    // dispatch(setHistoryPageSize(newPageSize))
    // dispatch(setPage(1))

    updateUrlPagination(1, newPageSize)
    console.log('Two')
  }

  return (
    <Card>
      <CardHeader
        title='User History'
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
              setAction={null}
              
              // setAction={setDateRange}
              initialStartDate={searchParams.get('startDate') ? new Date(startDate) : null}
              initialEndDate={searchParams.get('endDate') ? new Date(endDate) : null}
              showClearButton={searchParams.get('startDate') && searchParams.get('endDate')}
              onClear={() => {
                if (searchParams.get('startDate') && searchParams.get('endDate')) {
                  console.log('Run DateRanget')
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
          <Grid item xs={12}>
            <CustomTabList onChange={handleTabChange} variant='scrollable' pill='true'>
              <Tab
                value='coin'
                label='Coin History'
                icon={<i className='tabler-coin' />}
                iconPosition='start'
                className='ms-4'
              />
              <Tab value='call' label='Call History' icon={<i className='tabler-phone' />} iconPosition='start' />
              <Tab
                value='plan'
                label='Coin Plan History'
                icon={<i className='tabler-shopping-cart' />}
                iconPosition='start'
              />
            </CustomTabList>
          </Grid>
          <Grid item size={12}>
            <TabPanel value={activeTab} className='p-0'>
              {history?.loading ? (
                <Box className='flex justify-center items-center py-10'>
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
