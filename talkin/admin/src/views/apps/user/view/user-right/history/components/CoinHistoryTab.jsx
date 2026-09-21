'use client'

import { useEffect, useState } from 'react'

import { useInView } from 'react-intersection-observer'

// MUI Imports
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import CircularProgress from '@mui/material/CircularProgress'
import Alert from '@mui/material/Alert'
import Divider from '@mui/material/Divider'

// Component Imports
import { TransactionItem } from './TransactionItem'
import TransactionSkeleton from './TransactionSkeleton'
import EmptyState from './EmptyState'
import { TRANSACTION_TYPES } from '../constants'

const CoinHistoryTab = ({ history, loadTransactions, hasInitiallyLoaded }) => {
  const { ref, inView } = useInView()
  const [showInfoAlert, setShowInfoAlert] = useState(true)

  // Handle infinite scroll
  useEffect(() => {
    if (inView && !history.loading && history.hasMore) {
      loadTransactions()
    }
  }, [inView, history.loading, history.hasMore, loadTransactions])

  // Keep the existing effect for tracking the hasInitiallyLoaded state
  useEffect(() => {
    if (
      !hasInitiallyLoaded &&
      (!history.data || history.data.length === 0) &&
      history.hasMore &&
      !history.loading &&
      !history.initialLoading
    ) {
      loadTransactions()
    }
  }, [history.data, history.hasMore, history.loading, history.initialLoading, loadTransactions, hasInitiallyLoaded])

  console.log('history.hasMore', history.hasMore)

  const transactions = history.data || []
  const typeWiseStats = history.typeWiseStats || []

  // Get transaction type distribution
  const getTransactionTypeDistribution = () => {
    if (!typeWiseStats || typeWiseStats.length === 0) return null

    // Calculate totals
    const totalCounts = typeWiseStats.reduce((sum, stat) => sum + stat.count, 0)
    const totalCoins = typeWiseStats.reduce((sum, stat) => sum + stat.totalCoin, 0)

    // Sort by totalCoin in descending order
    const sortedStats = [...typeWiseStats].sort((a, b) => b.totalCoin - a.totalCoin)

    return (
      <Card variant='outlined' sx={{ mt: 3, mb: 4, borderRadius: 2, overflow: 'hidden' }}>
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

                      {/* {stat.totalCoin && (
                        <Box sx={{ mt: 2 }}>
                          <Typography variant='caption' color='text.secondary' fontWeight={500}>
                            COINS
                          </Typography>
                          <Typography variant='h6' fontWeight={600} color={`${color}.main`} sx={{ mt: 0.5 }}>
                            {stat.totalCoin.toLocaleString()}
                          </Typography>
                        </Box>
                      )} */}
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

  // Helper function to get transaction type name
  const getTransactionTypeName = type => {
    switch (type) {
      case TRANSACTION_TYPES.COIN_HISTORY:
        return 'Coin History'
      case TRANSACTION_TYPES.PURCHASE_THEME:
        return 'Theme Purchase'
      case TRANSACTION_TYPES.PURCHASE_AVTARFRAME:
        return 'Avatar Frame'
      case TRANSACTION_TYPES.PURCHASE_RIDE:
        return 'Ride Purchase'
      case TRANSACTION_TYPES.PRIVATE_CALL:
        return 'Private Call'
      case TRANSACTION_TYPES.LIVE_GIFT:
        return 'Live Gift'
      case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
        return 'Coin Purchase'
      case TRANSACTION_TYPES.REFERRAL_REWARD:
        return 'Referral Reward'
      case TRANSACTION_TYPES.LOGIN_BONUS:
        return 'Login Bonus'
      case TRANSACTION_TYPES.TEENPATTI_GAME:
        return 'Teen Patti Game'
      case TRANSACTION_TYPES.FERRYWHEEL_GAME:
        return 'Ferry Wheel Game'
      case TRANSACTION_TYPES.CASINO_GAME:
        return 'Casino Game'
      default:
        return 'Other'
    }
  }

  // Helper function to get transaction type icon
  const getTransactionTypeIcon = type => {
    switch (type) {
      case TRANSACTION_TYPES.COIN_HISTORY:
        return 'tabler-coins'
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
      case TRANSACTION_TYPES.REFERRAL_REWARD:
        return 'tabler-users'
      case TRANSACTION_TYPES.LOGIN_BONUS:
        return 'tabler-login'
      case TRANSACTION_TYPES.TEENPATTI_GAME:
        return 'tabler-cards'
      case TRANSACTION_TYPES.FERRYWHEEL_GAME:
        return 'tabler-wheel'
      case TRANSACTION_TYPES.CASINO_GAME:
        return 'tabler-dice'
      default:
        return 'tabler-history'
    }
  }

  // Helper function to get transaction type color
  const getTransactionTypeColor = type => {
    switch (type) {
      case TRANSACTION_TYPES.COIN_HISTORY:
        return 'primary'
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
      case TRANSACTION_TYPES.REFERRAL_REWARD:
        return 'success'
      case TRANSACTION_TYPES.LOGIN_BONUS:
        return 'info'
      case TRANSACTION_TYPES.TEENPATTI_GAME:
        return 'warning'
      case TRANSACTION_TYPES.FERRYWHEEL_GAME:
        return 'info'
      case TRANSACTION_TYPES.CASINO_GAME:
        return 'success'
      default:
        return 'primary'
    }
  }

  return (
    <>
      {/* Summary cards: only show for Coin History tab */}
      {!history.initialLoading && (
        <Card
          variant='outlined'
          sx={{
            mb: 4,
            borderRadius: 2,
            overflow: 'hidden',
            boxShadow: theme => theme.shadows[2]
          }}
        >
          <Box
            sx={{
              p: 3,
              background: theme =>
                `linear-gradient(45deg, ${theme.palette.primary.light}, ${theme.palette.primary.main})`
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
                <i className='tabler-coins' style={{ fontSize: '1.5rem', color: 'white' }}></i>
              </Box>
              <Typography variant='h6' sx={{ color: 'white', fontWeight: 600 }}>
                Coin History Summary
              </Typography>
            </Box>
          </Box>

          <CardContent sx={{ p: 3 }}>
            <Grid container spacing={3}>
              <Grid item xs={12} md={4}>
                <Card
                  variant='outlined'
                  sx={{
                    height: '100%',
                    p: 2,
                    borderRadius: 2,
                    borderLeft: '4px solid var(--mui-palette-primary-main)',
                    transition: 'transform 0.2s',
                    '&:hover': { transform: 'translateY(-4px)' }
                  }}
                >
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <Box
                      sx={{
                        width: 40,
                        height: 40,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        borderRadius: '50%',
                        bgcolor: 'primary.lightest',
                        mr: 2
                      }}
                    >
                      <i
                        className='tabler-history'
                        style={{ fontSize: '1.2rem', color: 'var(--mui-palette-primary-main)' }}
                      ></i>
                    </Box>
                    <Typography variant='subtitle2' color='text.secondary'>
                      Total Transactions
                    </Typography>
                  </Box>
                  <Typography variant='h4' fontWeight={700} sx={{ pl: 1 }}>
                    {history.total || 0}
                  </Typography>
                </Card>
              </Grid>

              <Grid item xs={12} md={4}>
                <Card
                  variant='outlined'
                  sx={{
                    height: '100%',
                    p: 2,
                    borderRadius: 2,
                    borderLeft: '4px solid var(--mui-palette-success-main)',
                    transition: 'transform 0.2s',
                    '&:hover': { transform: 'translateY(-4px)' }
                  }}
                >
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <Box
                      sx={{
                        width: 40,
                        height: 40,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        borderRadius: '50%',
                        bgcolor: 'success.lightest',
                        mr: 2
                      }}
                    >
                      <i
                        className='tabler-trending-up'
                        style={{ fontSize: '1.2rem', color: 'var(--mui-palette-success-main)' }}
                      ></i>
                    </Box>
                    <Typography variant='subtitle2' color='text.secondary'>
                      Total Income
                    </Typography>
                  </Box>
                  <Typography variant='h4' fontWeight={700} color='success.main' sx={{ pl: 1 }}>
                    +{history.totalIncome || 0}
                    <Typography component='span' variant='caption' sx={{ ml: 0.5 }}>
                      Coins
                    </Typography>
                  </Typography>
                </Card>
              </Grid>

              <Grid item xs={12} md={4}>
                <Card
                  variant='outlined'
                  sx={{
                    height: '100%',
                    p: 2,
                    borderRadius: 2,
                    borderLeft: '4px solid var(--mui-palette-error-main)',
                    transition: 'transform 0.2s',
                    '&:hover': { transform: 'translateY(-4px)' }
                  }}
                >
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <Box
                      sx={{
                        width: 40,
                        height: 40,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        borderRadius: '50%',
                        bgcolor: 'error.lightest',
                        mr: 2
                      }}
                    >
                      <i
                        className='tabler-trending-down'
                        style={{ fontSize: '1.2rem', color: 'var(--mui-palette-error-main)' }}
                      ></i>
                    </Box>
                    <Typography variant='subtitle2' color='text.secondary'>
                      Total Outgoing
                    </Typography>
                  </Box>
                  <Typography variant='h4' fontWeight={700} color='error.main' sx={{ pl: 1 }}>
                    -{history.totalOutgoing || 0}
                    <Typography component='span' variant='caption' sx={{ ml: 0.5 }}>
                      Coins
                    </Typography>
                  </Typography>
                </Card>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      )}

      {/* Transaction Type Distribution */}
      {!history.initialLoading && transactions.length > 0 && getTransactionTypeDistribution()}

      {/* Transactions List */}
      {history.initialLoading ? (
        <Box>
          {[...Array(5)].map((_, index) => (
            <TransactionSkeleton key={index} />
          ))}
        </Box>
      ) : transactions.length > 0 ? (
        <Box>
          {transactions.map((transaction, index) => (
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
      ) : (
        <EmptyState message='No coin history transactions found for this user.' icon='tabler-coins' />
      )}
    </>
  )
}

export default CoinHistoryTab
