'use client'

import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Divider from '@mui/material/Divider'
import Paper from '@mui/material/Paper'
import Stack from '@mui/material/Stack'
import Typography from '@mui/material/Typography'

import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'
import CustomAvatar from '@core/components/mui/Avatar'
import { TRANSACTION_TYPES, TYPE_LABELS } from '../apps/user/view/user-right/history/constants'

const TransactionItem = ({ transaction, transactionType }) => {
  const displayType = transactionType || parseInt(transaction.type)

  const getAvatar = params => {
    const { avatar, fullName } = params

    if (avatar) {
      return <CustomAvatar src={avatar} size={40} className={'border-2 '} />
    } else {
      return <CustomAvatar size={40}>{getInitials(fullName)}</CustomAvatar>
    }
  }

  // The original transaction type is used for icons/colors
  const actualType = parseInt(transaction.type)

  const getTransactionIcon = type => {
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

  const getTransactionColor = type => {
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

  const formatDate = dateString => {
    if (!dateString) return 'N/A'

    const date = new Date(dateString)

    return new Intl.DateTimeFormat('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    }).format(date)
  }

  // Format duration to make it more readable
  const formatDuration = duration => {
    if (!duration || duration === '00:00:00') return 'Not available'

    return duration
  }

  // Get validity display text combining validity and type
  const getValidityText = (validity, validityType) => {
    if (!validity || validity === 0) return 'Not specified'

    let typeText = ''

    switch (validityType) {
      case 1:
        typeText = `${validity} Day(s)`
        break
      case 2:
        typeText = `${validity} Month(s)`
        break
      case 3:
        typeText = `${validity} Year(s)`
        break
      default:
        typeText = `${validity} Day(s)` // Default to days if type not specified
    }

    return typeText
  }

  const payoutStatus = {
    1: 'Pending',
    2: 'Accepted',
    3: 'Declined'
  }
  
  // Decide what details to show based on the current tab context (displayType)
  const renderTransactionDetails = () => {
    // Always use the display type (from tab context) to determine what details to show
    switch (displayType) {
      case TRANSACTION_TYPES.PRIVATE_VIDEO_CALL:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Box
              display='flex'
              justifyContent='space-between'
              alignItems='flex-start'
              sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
            >
              <Box>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Started
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callStartTime)}</Typography>
              </Box>
              <Box textAlign='right'>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Ended
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callEndTime)}</Typography>
              </Box>
            </Box>

            {/* align left on mobile and center on laptop */}
            {/* Display both sender and receiver information for private calls */}
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='flex-start' mt={2}>
              {transaction.fullName && (
                <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                  <div className='flex items-center gap-4 mr-1.5'>
                    {getAvatar({
                      avatar: getFullImageUrl(transaction?.profilePic),
                      fullName: transaction?.fullName
                    })}
                  </div>
                  <Box>
                    <Typography variant='caption' color='text.secondary'>
                      Receiver
                    </Typography>
                    <Typography variant='body2'>{transaction.fullName}</Typography>
                  </Box>
                </Box>
              )}
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-crown'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Caller Role
                  </Typography>
                  <Typography variant='body2'>{transaction?.callerRole}</Typography>
                </Box>
              </Box>
            </Stack>
            <Stack
              direction={{ xs: 'column', sm: 'row' }}
              mt={2}
              spacing={2}
              alignItems={{ xs: 'flex-start', lg: 'center' }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-clock-12'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Duration
                  </Typography>
                  <Typography variant='body2'>{formatDuration(transaction.duration)}</Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-phone-spark'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Call status
                  </Typography>
                  <Typography variant='body2'>{transaction?.callStatusText || '-'}</Typography>
                </Box>
              </Box>
            </Stack>
            <Divider className='my-2' />
            <Box className='flex items-center gap-2 justify-start flex-wrap'>
              <Chip variant='tonal' label={`User : ${transaction?.userCoin || '0'} Coins`} size='small' color='info' />
              <Chip
                variant='tonal'
                label={`Listener : ${transaction?.listenerCoin || '0'} Coins`}
                size='small'
                color='success'
              />
              <Chip
                variant='tonal'
                label={`Admin : ${transaction?.adminCoin || '0'} Coins`}
                size='small'
                color='warning'
              />
            </Box>
          </Box>
        )
      case TRANSACTION_TYPES.RANDOM_VIDEO_CALL:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Box
              display='flex'
              justifyContent='space-between'
              alignItems='flex-start'
              sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
            >
              <Box>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Started
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callStartTime)}</Typography>
              </Box>
              <Box textAlign='right'>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Ended
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callEndTime)}</Typography>
              </Box>
            </Box>

            {/* align left on mobile and center on laptop */}
            {/* Display both sender and receiver information for private calls */}
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='flex-start' mt={2}>
              {transaction.fullName && (
                <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                  <div className='flex items-center gap-4 mr-1.5'>
                    {getAvatar({
                      avatar: getFullImageUrl(transaction?.profilePic),
                      fullName: transaction?.fullName
                    })}
                  </div>
                  <Box>
                    <Typography variant='caption' color='text.secondary'>
                      Receiver
                    </Typography>
                    <Typography variant='body2'>{transaction.fullName}</Typography>
                  </Box>
                </Box>
              )}
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-crown'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Caller Role
                  </Typography>
                  <Typography variant='body2'>{transaction?.callerRole}</Typography>
                </Box>
              </Box>
            </Stack>
            <Stack
              direction={{ xs: 'column', sm: 'row' }}
              mt={2}
              spacing={2}
              alignItems={{ xs: 'flex-start', lg: 'center' }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-clock-12'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Duration
                  </Typography>
                  <Typography variant='body2'>{formatDuration(transaction.duration)}</Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-phone-spark'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Call status
                  </Typography>
                  <Typography variant='body2'>{transaction?.callStatusText || '-'}</Typography>
                </Box>
              </Box>
            </Stack>
            <Divider className='my-2' />
            <Box className='flex items-center gap-2 justify-start flex-wrap'>
              <Chip variant='tonal' label={`User : ${transaction?.userCoin || '0'} Coins`} size='small' color='info' />
              <Chip
                variant='tonal'
                label={`Listener : ${transaction?.listenerCoin || '0'} Coins`}
                size='small'
                color='success'
              />
              <Chip
                variant='tonal'
                label={`Admin : ${transaction?.adminCoin || '0'} Coins`}
                size='small'
                color='warning'
              />
            </Box>
          </Box>
        )
      case TRANSACTION_TYPES.RANDOM_AUDIO_CALL:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Box
              display='flex'
              justifyContent='space-between'
              alignItems='flex-start'
              sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
            >
              <Box>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Started
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callStartTime)}</Typography>
              </Box>
              <Box textAlign='right'>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Ended
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callEndTime)}</Typography>
              </Box>
            </Box>

            {/* align left on mobile and center on laptop */}
            {/* Display both sender and receiver information for private calls */}
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='flex-start' mt={2}>
              {transaction.fullName && (
                <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                  <div className='flex items-center gap-4 mr-1.5'>
                    {getAvatar({
                      avatar: getFullImageUrl(transaction?.profilePic),
                      fullName: transaction?.fullName
                    })}
                  </div>
                  <Box>
                    <Typography variant='caption' color='text.secondary'>
                      Receiver
                    </Typography>
                    <Typography variant='body2'>{transaction.fullName}</Typography>
                  </Box>
                </Box>
              )}
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-crown'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Caller Role
                  </Typography>
                  <Typography variant='body2'>{transaction?.callerRole}</Typography>
                </Box>
              </Box>
            </Stack>
            <Stack
              direction={{ xs: 'column', sm: 'row' }}
              mt={2}
              spacing={2}
              alignItems={{ xs: 'flex-start', lg: 'center' }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-clock-12'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Duration
                  </Typography>
                  <Typography variant='body2'>{formatDuration(transaction.duration)}</Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-phone-spark'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Call status
                  </Typography>
                  <Typography variant='body2'>{transaction?.callStatusText || '-'}</Typography>
                </Box>
              </Box>
            </Stack>
            <Divider className='my-2' />
            <Box className='flex items-center gap-2 justify-start flex-wrap'>
              <Chip variant='tonal' label={`User : ${transaction?.userCoin || '0'} Coins`} size='small' color='info' />
              <Chip
                variant='tonal'
                label={`Listener : ${transaction?.listenerCoin || '0'} Coins`}
                size='small'
                color='success'
              />
              <Chip
                variant='tonal'
                label={`Admin : ${transaction?.adminCoin || '0'} Coins`}
                size='small'
                color='warning'
              />
            </Box>
          </Box>
        )
      case TRANSACTION_TYPES.PRIVATE_AUDIO_CALL:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Box
              display='flex'
              justifyContent='space-between'
              alignItems='flex-start'
              sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
            >
              <Box>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Started
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callStartTime)}</Typography>
              </Box>
              <Box textAlign='right'>
                <Typography variant='caption' color='text.secondary' display='block'>
                  Ended
                </Typography>
                <Typography variant='body2'>{formatDate(transaction.callEndTime)}</Typography>
              </Box>
            </Box>

            {/* align left on mobile and center on laptop */}
            {/* Display both sender and receiver information for private calls */}
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='flex-start' mt={2}>
              {transaction.fullName && (
                <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                  <div className='flex items-center gap-4 mr-1.5'>
                    {getAvatar({
                      avatar: getFullImageUrl(transaction?.profilePic),
                      fullName: transaction?.fullName
                    })}
                  </div>
                  <Box>
                    <Typography variant='caption' color='text.secondary'>
                      Receiver
                    </Typography>
                    <Typography variant='body2'>{transaction.fullName}</Typography>
                  </Box>
                </Box>
              )}
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-crown'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Caller Role
                  </Typography>
                  <Typography variant='body2'>{transaction?.callerRole}</Typography>
                </Box>
              </Box>
            </Stack>
            <Stack
              direction={{ xs: 'column', sm: 'row' }}
              mt={2}
              spacing={2}
              alignItems={{ xs: 'flex-start', lg: 'center' }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-clock-12'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Duration
                  </Typography>
                  <Typography variant='body2'>{formatDuration(transaction.duration)}</Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='success' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-phone-spark'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Call status
                  </Typography>
                  <Typography variant='body2'>{transaction?.callStatusText || '-'}</Typography>
                </Box>
              </Box>
            </Stack>
            <Divider className='my-2' />
            <Box className='flex items-center gap-2 justify-start flex-wrap'>
              <Chip variant='tonal' label={`User : ${transaction?.userCoin || '0'} Coins`} size='small' color='info' />
              <Chip
                variant='tonal'
                label={`Listener : ${transaction?.listenerCoin || '0'} Coins`}
                size='small'
                color='success'
              />
              <Chip
                variant='tonal'
                label={`Admin : ${transaction?.adminCoin || '0'} Coins`}
                size='small'
                color='warning'
              />
            </Box>
          </Box>
        )

      case TRANSACTION_TYPES.COIN_PLAN_PURCHASE:
        return (
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
        )
      case TRANSACTION_TYPES.WITHDRAWAL_BY_LISTENER:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Box
              display='flex'
              justifyContent='space-between'
              alignItems='flex-start'
              sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
            ></Box>

            <Stack
              direction={{ xs: 'column', sm: 'row' }}
              mt={2}
              spacing={2}
              alignItems={{ xs: 'flex-start', lg: 'center' }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='primary' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-credit-card-pay'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Payment Gateway
                  </Typography>
                  <Typography variant='body2'>{transaction.paymentGateway || '-'}</Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='primary' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-file-text-spark'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Payout status
                  </Typography>
                  <Typography variant='body2'>{payoutStatus[transaction?.payoutStatus]}</Typography>
                </Box>
              </Box>
            </Stack>
          </Box>
        )
      case TRANSACTION_TYPES.LOGIN_BONUS:
        return (
          <Box className='transaction-details mt-3'>
            <Divider sx={{ mb: 2 }} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='center'>
              <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                <CustomAvatar skin='light' color='secondary' size='sm' sx={{ mr: 1.5 }}>
                  <i className='tabler-login'></i>
                </CustomAvatar>
                <Box>
                  <Typography variant='caption' color='text.secondary'>
                    Bonus Type
                  </Typography>
                  <Typography variant='body2'>Login Bonus</Typography>
                </Box>
              </Box>
              {transaction.loginStreak && (
                <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                  <CustomAvatar skin='light' color='info' size='sm' sx={{ mr: 1.5 }}>
                    <i className='tabler-calendar-check'></i>
                  </CustomAvatar>
                  <Box>
                    <Typography variant='caption' color='text.secondary'>
                      Login Streak
                    </Typography>
                    <Typography variant='body2'>{transaction.loginStreak} days</Typography>
                  </Box>
                </Box>
              )}
            </Stack>
          </Box>
        )

      default:
        // For coin history or other transaction types with minimal info
        if (transaction.senderName || transaction.fullName) {
          return (
            <Box className='transaction-details mt-3'>
              <Divider sx={{ mb: 2 }} />
              <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems='flex-start'>
                {transaction.senderName && (
                  <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                    <CustomAvatar skin='light' color='primary' size='sm' sx={{ mr: 1.5 }}>
                      <i className='tabler-arrow-up'></i>
                    </CustomAvatar>
                    <Box>
                      <Typography variant='caption' color='text.secondary'>
                        Sender
                      </Typography>
                      <Typography variant='body2'>{transaction.senderName}</Typography>
                    </Box>
                  </Box>
                )}

                {transaction.fullName && (
                  <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                    <div className='flex items-center gap-4 mr-1.5'>
                      {getAvatar({ avatar: getFullImageUrl(transaction?.profilePic), fullName: transaction?.fullName })}
                    </div>
                    <Box>
                      <Typography variant='caption' color='text.secondary'>
                        Receiver
                      </Typography>
                      <Typography variant='body2'>{transaction.fullName}</Typography>
                    </Box>
                  </Box>
                )}
                {transaction.callerRole && (
                  <Box sx={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                    <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                      <i className='tabler-crown'></i>
                    </CustomAvatar>

                    <Box>
                      <Typography variant='caption' color='text.secondary'>
                        Caller Role
                      </Typography>
                      <Typography variant='body2' textTransform={'capitalize'}>
                        {transaction.callerRole}
                      </Typography>
                    </Box>
                  </Box>
                )}
              </Stack>
            </Box>
          )
        }

        return null
    }
  }

  // Get the display label based on the context
  const getTransactionLabel = () => {
    // For items in specific tabs, use that tab's type label
    if (transactionType) {
      return TYPE_LABELS[transactionType]
    }

    // Otherwise, use the actual transaction type
    return TYPE_LABELS[actualType] || 'Transaction'
  }

  // This allows showing that the actual type might be different from the tab context
  const shouldShowActualTypeChip = transactionType && actualType !== transactionType

  return (
    <Paper elevation={0} className='p-4 border rounded-md mb-3'>
      {/* Header with avatar and transaction info */}
      <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 3 }} className='md:flex-row flex-col'>
        <Box className='flex items-center justify-between w-full md:w-auto'>
          <CustomAvatar skin='light' color={getTransactionColor(transactionType || actualType)} variant='rounded'>
            <i className={getTransactionIcon(transactionType || actualType)} />
          </CustomAvatar>
          {/* show on mobile */}
          <Box sx={{ textAlign: 'right', display: { xs: 'block', md: 'none' } }}>
            <Typography variant='body2' sx={{ fontWeight: 600 }} color={'success.main'}>
              {transaction?.type === 7 ? '-' : '+'}
              {transaction.listenerCoin} Coins
            </Typography>
          </Box>
        </Box>

        {/* Transaction details */}
        <Box sx={{ flexGrow: 1 }}>
          {/* Top row with transaction type and amount */}
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box>
              <Typography variant='subtitle2'>{getTransactionLabel()}</Typography>
              <Box display='flex' gap={2} alignItems='center'>
                <Typography variant='caption' color='text.secondary'>
                  ID: {transaction.uniqueId} | {formatDate(transaction.createdAt)}
                </Typography>

                {transaction.isRandom
                  ? ![1, 2, 7].includes(transaction?.type) && (
                      <Chip variant='tonal' label='Random' size='small' color='success' sx={{ ml: 'auto' }} />
                    )
                  : ![1, 2, 7].includes(transaction?.type) && (
                      <Chip variant='tonal' label='Private' size='small' color='error' sx={{ ml: 'auto' }} />
                    )}
              </Box>
            </Box>
            {/* hide on mobile */}
            <Box sx={{ textAlign: 'right', display: { xs: 'none', md: 'block' } }}>
              {transaction?.type == 7 ? (
                <Typography variant='body2' sx={{ fontWeight: 600 }} color={transaction?.payoutStatus === 2 ? 'error.main' : "warning.main"}>
                 {transaction?.payoutStatus === 2 ? "-" : ""}  {transaction.listenerCoin} Coins
                </Typography>
              ) : (
                <Typography variant='body2' sx={{ fontWeight: 600 }} color={'success.main'}>
                 +{transaction.listenerCoin} Coins
                </Typography>
              )}
            </Box>
          </Box>

          {/* Transaction specific details based on the current tab context */}
          {renderTransactionDetails()}
        </Box>
      </Box>
    </Paper>
  )
}

export { TransactionItem }
