'use client'

import { useEffect } from 'react'

import { useInView } from 'react-intersection-observer'

// MUI Imports
import Box from '@mui/material/Box'
import Tabs from '@mui/material/Tabs'
import Tab from '@mui/material/Tab'
import Typography from '@mui/material/Typography'
import CircularProgress from '@mui/material/CircularProgress'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import Divider from '@mui/material/Divider'

// Component Imports
import { TransactionItem } from './TransactionItem'
import TransactionSkeleton from './TransactionSkeleton'
import EmptyState from './EmptyState'

// Constants
import { TRANSACTION_TYPES, TYPE_LABELS } from '../constants'

const TransactionsTab = ({ history, transactionTab, setTransactionTab, loadTransactions, hasInitiallyLoaded }) => {
  const { ref, inView } = useInView()

  // Keep the existing effect for tracking hasInitiallyLoaded
  useEffect(() => {
    if (
      !hasInitiallyLoaded &&
      (!history.filteredData || history.filteredData.length === 0) &&
      history.hasMore &&
      !history.loading &&
      !history.initialLoading
    ) {
      loadTransactions()
    }
  }, [
    history.filteredData,
    history.hasMore,
    history.loading,
    history.initialLoading,
    loadTransactions,
    hasInitiallyLoaded
  ])

  // Handle infinite scroll
  useEffect(() => {
    if (inView && !history.loading && history.hasMore) {
      loadTransactions()
    }
  }, [inView, history.loading, history.hasMore, loadTransactions])

  // Handle transaction type tab change
  const handleTransactionTabChange = (event, newValue) => {
    // Always update the parent component with the new value
    setTransactionTab(newValue)
  }

  // Run an effect when transactionTab changes from parent
  useEffect(() => {
    // This ensures that when the parent changes transactionTab, we respect it
    // This is important for tab resets from the parent component
    if (transactionTab) {
      // The parent component will handle paginations resets
      // This just ensures we use the correct tab
    }
  }, [transactionTab])

  const transactions = history.filteredData || []

  // Get the appropriate icon for the current transaction type
  const getTransactionTypeIcon = type => {
    switch (type) {
      case TRANSACTION_TYPES.PURCHASE_THEME:
        return 'tabler-palette'
      case TRANSACTION_TYPES.PURCHASE_AVTARFRAME:
        return 'tabler-frame'
      case TRANSACTION_TYPES.PURCHASE_RIDE:
        return 'tabler-car'
      case TRANSACTION_TYPES.PRIVATE_CALL:
        return 'tabler-phone'
      case TRANSACTION_TYPES.LIVE_GIFT:
        return 'tabler-gift'
      case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
        return 'tabler-coin'
      default:
        return 'tabler-history'
    }
  }

  // Get the color for the current transaction type
  const getTransactionTypeColor = type => {
    switch (type) {
      case TRANSACTION_TYPES.PURCHASE_THEME:
        return 'warning'
      case TRANSACTION_TYPES.PURCHASE_AVTARFRAME:
        return 'info'
      case TRANSACTION_TYPES.PURCHASE_RIDE:
        return 'secondary'
      case TRANSACTION_TYPES.PRIVATE_CALL:
        return 'error'
      case TRANSACTION_TYPES.LIVE_GIFT:
        return 'success'
      case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
        return 'primary'
      default:
        return 'primary'
    }
  }

  // Get validity type display text
  const getValidityTypeDisplay = type => {
    switch (type) {
      case 1:
        return 'Day(s)'
      case 2:
        return 'Month(s)'
      case 3:
        return 'Year(s)'
      default:
        return ''
    }
  }

  // Get transaction summary information
  const getTransactionSummary = () => {
    if (!transactions || transactions.length === 0) return null

    const color = getTransactionTypeColor(transactionTab)
    const icon = getTransactionTypeIcon(transactionTab)

    let totalIncoming = 0
    let totalOutgoing = 0

    transactions.forEach(t => {
      const coinValue = t.coin || 0

      if (t.isIncome) {
        totalIncoming += coinValue
      } else {
        totalOutgoing += coinValue
      }
    })

    // Prepare validity counts if applicable
    const validityTypes = {}

    switch (transactionTab) {
      case TRANSACTION_TYPES.PURCHASE_THEME:
        transactions.forEach(t => {
          const type = t.themeValidityType || 'Unknown'
          const validityDisplay = getValidityTypeDisplay(type)
          const key = `${validityDisplay} (Type ${type})`

          validityTypes[key] = (validityTypes[key] || 0) + 1
        })
        break

      case TRANSACTION_TYPES.PURCHASE_AVTARFRAME:
        transactions.forEach(t => {
          const type = t.avtarFrameValidityType || 'Unknown'
          const validityDisplay = getValidityTypeDisplay(type)
          const key = `${validityDisplay} (Type ${type})`

          validityTypes[key] = (validityTypes[key] || 0) + 1
        })
        break

      case TRANSACTION_TYPES.PURCHASE_RIDE:
        transactions.forEach(t => {
          const type = t.rideValidityType || 'Unknown'
          const validityDisplay = getValidityTypeDisplay(type)
          const key = `${validityDisplay} (Type ${type})`

          validityTypes[key] = (validityTypes[key] || 0) + 1
        })
        break
    }

    return (
      <Card variant='outlined' sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <Box
              sx={{
                width: 40,
                height: 40,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: 2,
                backgroundColor: `${color}.lightest`,
                mr: 2
              }}
            >
              <i className={`${icon} text-${color}`} style={{ fontSize: '1.5rem' }}></i>
            </Box>
            <Typography variant='h6'>{TYPE_LABELS[transactionTab]} Summary</Typography>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container justifyContent='space-evenly'>
            <Grid item xs={12} sm={6} md={4}>
              <Typography variant='body2' color='text.secondary'>
                Total Transactions:
              </Typography>
              <Typography variant='h6' align='center'>
                {history.total || transactions.length}
              </Typography>
            </Grid>

            {/* Handle based on transaction type */}
            {(transactionTab === TRANSACTION_TYPES.PRIVATE_CALL || transactionTab === TRANSACTION_TYPES.LIVE_GIFT) && (
              <>
                <Grid item xs={12} sm={6} md={4}>
                  <Typography variant='body2' color='text.secondary'>
                    Coins Received:
                  </Typography>
                  <Typography variant='h6' color='success.main' align='center'>
                    +{totalIncoming} Coins
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6} md={4}>
                  <Typography variant='body2' color='text.secondary'>
                    Coins Spent:
                  </Typography>
                  <Typography variant='h6' color='error.main' align='center'>
                    -{totalOutgoing} Coins
                  </Typography>
                </Grid>
              </>
            )}

            {transactionTab === TRANSACTION_TYPES.COIN_PLAN_PURCHASE && (
              <Grid item xs={12} sm={6} md={4}>
                <Typography variant='body2' color='text.secondary'>
                  Coins Purchased:
                </Typography>
                <Typography variant='h6' color='success.main' align='center'>
                  +{totalIncoming} Coins
                </Typography>
              </Grid>
            )}

            {![
              TRANSACTION_TYPES.PRIVATE_CALL,
              TRANSACTION_TYPES.LIVE_GIFT,
              TRANSACTION_TYPES.COIN_PLAN_PURCHASE
            ].includes(transactionTab) && (
              <Grid item xs={12} sm={6} md={4}>
                <Typography variant='body2' color='text.secondary'>
                  Total Coins Spent:
                </Typography>
                <Typography variant='h6' color='error.main' align='center'>
                  -{totalOutgoing} Coins
                </Typography>
              </Grid>
            )}
          </Grid>
        </CardContent>
      </Card>
    )
  }

  return (
    <>
      {/* Transaction Type Tabs */}
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs
          value={transactionTab}
          onChange={handleTransactionTabChange}
          variant='scrollable'
          scrollButtons='auto'
          aria-label='transaction type tabs'
        >
          <Tab label='Theme Purchase' value={TRANSACTION_TYPES.PURCHASE_THEME} />
          <Tab label='Frame Purchase' value={TRANSACTION_TYPES.PURCHASE_AVTARFRAME} />
          <Tab label='Ride Purchase' value={TRANSACTION_TYPES.PURCHASE_RIDE} />
          <Tab label='Private Call' value={TRANSACTION_TYPES.PRIVATE_CALL} />
          <Tab label='Live Gift' value={TRANSACTION_TYPES.LIVE_GIFT} />
          <Tab label='Coin Plan Purchase' value={TRANSACTION_TYPES.COIN_PLAN_PURCHASE} />
        </Tabs>
      </Box>

      {/* Transaction Summary (only show when transactions exist) */}
      {!history.initialLoading && transactions.length > 0 && getTransactionSummary()}

      {/* Transactions List Based on Type */}
      {history.initialLoading ? (
        <Box>
          {[...Array(5)].map((_, index) => (
            <TransactionSkeleton key={index} />
          ))}
        </Box>
      ) : transactions.length > 0 ? (
        <Box>
          {transactions.map((transaction, index) => (
            <TransactionItem
              key={`${transaction._id}-${index}`}
              transaction={transaction}
              transactionType={transactionTab}
            />
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
      ) : (
        <EmptyState
          message={`No ${TYPE_LABELS[transactionTab]} transactions found.`}
          icon={getTransactionTypeIcon(transactionTab)}
        />
      )}
    </>
  )
}

export default TransactionsTab
