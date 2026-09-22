'use client'

import { useEffect, useState, useCallback } from 'react'

import { useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Divider from '@mui/material/Divider'
import Box from '@mui/material/Box'
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'

// Next Imports

// Component Imports
import TabPanel from './components/TabPanel'
import CoinHistoryTab from './components/CoinHistoryTab'
import TransactionsTab from './components/TransactionsTab'
import EmptyState from './components/EmptyState'
import LiveStreamTab from './components/LiveStreamTab'
import { TRANSACTION_TYPES } from './constants'

// Redux actions
import {
  fetchCoinHistory,
  fetchFilteredCoinHistory,
  fetchLiveStreamHistory,
  resetHistoryState,
  setDateRange
} from '@/redux-store/slices/user'
import DateRangePicker from '@/components/common/DateRangePicker'

// Transaction Type Labels
const TYPE_LABELS = {
  [TRANSACTION_TYPES.ALL]: 'All',
  [TRANSACTION_TYPES.COIN_HISTORY]: 'Coin History',
  [TRANSACTION_TYPES.PURCHASE_THEME]: 'Theme Purchase',
  [TRANSACTION_TYPES.PURCHASE_AVTARFRAME]: 'Avatar Frame',
  [TRANSACTION_TYPES.PURCHASE_RIDE]: 'Ride Purchase',
  [TRANSACTION_TYPES.PRIVATE_CALL]: 'Private Call',
  [TRANSACTION_TYPES.LIVE_GIFT]: 'Live Gift',
  [TRANSACTION_TYPES.COIN_PLAN_PURCHASE]: 'Coin Plan Purchase',
  [TRANSACTION_TYPES.TEENPATTI_GAME]: 'Teen Patti Game',
  [TRANSACTION_TYPES.FERRYWHEEL_GAME]: 'Ferry Wheel Game',
  [TRANSACTION_TYPES.CASINO_GAME]: 'Casino Game'
}

// Main history component
const HistoryTab = ({ userDetails }) => {
  const dispatch = useDispatch()
  const router = useRouter()
  const searchParams = useSearchParams()
  const history = useSelector(state => state.userReducer.history)
  const { startDate, endDate } = useSelector(state => state.userReducer)

  // Get tab parameters from URL or use defaults
  const historyTabParam = parseInt(searchParams.get('historyTab') || '0')
  const transactionTypeParam = parseInt(searchParams.get('transactionType') || TRANSACTION_TYPES.PURCHASE_THEME)

  const [mainTab, setMainTab] = useState(historyTabParam)
  const [transactionTab, setTransactionTab] = useState(transactionTypeParam)
  const [hasInitiallyLoaded, setHasInitiallyLoaded] = useState(false)

  // Helper to update URL params
  const updateUrlParams = useCallback(
    (key, value) => {
      const params = new URLSearchParams(searchParams.toString())

      params.set(key, value)
      router.push(`?${params.toString()}`, { scroll: false })
    },
    [router, searchParams]
  )

  // Sync URL with state when tabs change externally
  useEffect(() => {
    if (historyTabParam !== mainTab) {
      setMainTab(historyTabParam)

      // Reset transaction tab to default when switching to transaction tab from another parent tab
      if (historyTabParam === 1 && mainTab !== 1) {
        setTransactionTab(TRANSACTION_TYPES.PURCHASE_THEME)
        updateUrlParams('transactionType', TRANSACTION_TYPES.PURCHASE_THEME)
      }
    }

    if (transactionTypeParam !== transactionTab && mainTab === 1) {
      setTransactionTab(transactionTypeParam)
    }
  }, [historyTabParam, transactionTypeParam, mainTab, transactionTab, updateUrlParams])

  // Set up initial data load
  useEffect(() => {
    if (userDetails?._id) {
      dispatch(resetHistoryState())
      setHasInitiallyLoaded(false)
      loadTransactions()
    }

    return () => {
      dispatch(resetHistoryState())
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [userDetails?._id, mainTab, transactionTab, startDate, endDate, dispatch])

  // Load transactions based on current tab
  const loadTransactions = useCallback(() => {
    if (!userDetails?._id) return

    const params = {
      userId: userDetails._id,
      start: history.page,
      limit: history.limit,
      startDate: startDate || 'All',
      endDate: endDate || 'All'
    }

    if (mainTab === 0) {
      // Coin History Tab
      dispatch(fetchCoinHistory(params))
      setHasInitiallyLoaded(true)
    } else if (mainTab === 1) {
      // Transactions Tab with specific type
      dispatch(fetchFilteredCoinHistory({ ...params, type: transactionTab }))
      setHasInitiallyLoaded(true)
    } else if (mainTab === 2) {
      // Live Stream History Tab
      dispatch(fetchLiveStreamHistory(params))
      setHasInitiallyLoaded(true)
    }
  }, [dispatch, history.page, history.limit, mainTab, transactionTab, userDetails, startDate, endDate])

  // Handle main tab change
  const handleMainTabChange = (event, newValue) => {
    setMainTab(newValue)

    // Create a new URLSearchParams object
    const params = new URLSearchParams(searchParams.toString())

    // Set the new historyTab
    params.set('historyTab', newValue)

    // Remove transactionType from params when switching between main tabs
    // This ensures transaction tab resets when returning to transactions
    if (newValue !== 1) {
      params.delete('transactionType')
    }

    // Update URL without the transactionType param when not on transaction tab
    router.push(`?${params.toString()}`, { scroll: false })

    dispatch(resetHistoryState())
    setHasInitiallyLoaded(false)
  }

  // Handle transaction tab change with reset pagination
  const handleTransactionTabChange = newValue => {
    setTransactionTab(newValue)
    updateUrlParams('transactionType', newValue)
    dispatch(resetHistoryState())
    setHasInitiallyLoaded(false)
  }

  if (userDetails?.isFake) {
    return null
  }

  return (
    <Grid container spacing={6}>
      <Grid size={{ xs: 12 }}>
        <Card>
          <CardContent>
            <Box className='mb-2'>
              <Box className='flex justify-between mb-4'>
                <Typography variant='h5'>User History</Typography>

                {/* Date Range Picker */}
                <DateRangePicker
                  buttonText={startDate !== 'All' && endDate !== 'All' ? `${startDate} - ${endDate}` : 'Date Range'}
                  buttonStartIcon={<i className='tabler-calendar' />}
                  setAction={setDateRange}
                  initialStartDate={startDate !== 'All' ? new Date(startDate) : null}
                  initialEndDate={endDate !== 'All' ? new Date(endDate) : null}
                />
              </Box>
              <Divider />
            </Box>

            {/* Main tabs: Coin History, Transactions, and Live Stream */}
            <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
              <Tabs value={mainTab} onChange={handleMainTabChange} aria-label='history main tabs'>
                <Tab label='Coin History' />
                <Tab label='Transactions' />
                <Tab label='Live Stream' />
              </Tabs>
            </Box>

            {/* Coin History Tab Content */}
            <TabPanel value={mainTab} index={0}>
              <CoinHistoryTab
                history={history}
                loadTransactions={loadTransactions}
                hasInitiallyLoaded={hasInitiallyLoaded}
              />
            </TabPanel>

            {/* Transactions Tab Content */}
            <TabPanel value={mainTab} index={1}>
              <TransactionsTab
                history={history}
                transactionTab={transactionTab}
                setTransactionTab={handleTransactionTabChange}
                loadTransactions={loadTransactions}
                hasInitiallyLoaded={hasInitiallyLoaded}
              />
            </TabPanel>

            {/* Live Stream Tab Content */}
            <TabPanel value={mainTab} index={2}>
              <LiveStreamTab
                history={history}
                loadTransactions={loadTransactions}
                hasInitiallyLoaded={hasInitiallyLoaded}
              />
            </TabPanel>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default HistoryTab
