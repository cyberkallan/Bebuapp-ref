'use client'

import { useMemo } from 'react'

import { useInView } from 'react-intersection-observer'

// MUI Imports
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import Divider from '@mui/material/Divider'
import Grid from '@mui/material/Grid'
import Paper from '@mui/material/Paper'
import Typography from '@mui/material/Typography'

// Component Imports
import CustomAvatar from '@/@core/components/mui/Avatar'
import { getFullImageUrl } from '@/utils/commonfunctions'
import { getInitials } from '@/utils/getInitials'
import EmptyState from './EmptyState'
import TransactionSkeleton from './TransactionSkeleton'

const LiveStreamTab = ({ history, loadTransactions, hasInitiallyLoaded }) => {
  const { ref, inView } = useInView()

  // Use memoization to prevent the dependencies of useEffect from changing on every render
  const liveStreams = useMemo(() => history.data || [], [history.data])

  // Keep the existing effect for tracking hasInitiallyLoaded
  // useEffect(() => {
  //   if (
  //     !hasInitiallyLoaded &&
  //     (!liveStreams || liveStreams.length === 0) &&
  //     history.hasMore &&
  //     !history.loading &&
  //     !history.initialLoading
  //   ) {
  //     loadTransactions()
  //   }
  // }, [liveStreams, history.hasMore, history.loading, history.initialLoading, loadTransactions, hasInitiallyLoaded])

  // Handle infinite scroll
  // useEffect(() => {
  //   if (inView && !history.loading && history.hasMore) {
  //     loadTransactions()
  //   }
  // }, [inView, history.loading, history.hasMore, loadTransactions])

  // Format duration from "HH:MM:SS" to a readable format
  const formatDuration = duration => {
    if (!duration) return 'N/A'

    // If it's already in "HH:MM:SS" format, parse and format it
    if (typeof duration === 'string' && duration.includes(':')) {
      const parts = duration.split(':')
      const hours = parseInt(parts[0])
      const minutes = parseInt(parts[1])
      const seconds = parseInt(parts[2] || 0)

      if (hours > 0) {
        return `${hours}h ${minutes}m ${seconds}s`
      } else if (minutes > 0) {
        return `${minutes}m ${seconds}s`
      } else {
        return `${seconds}s`
      }
    }

    // For backward compatibility, handle numeric duration in seconds
    const minutes = Math.floor(duration / 60)
    const seconds = duration % 60

    return minutes > 0 ? `${minutes}m ${seconds}s` : `${seconds}s`
  }

  // Format date to "Month DD, YYYY, HH:MM AM/PM" format
  const formatDate = dateString => {
    if (!dateString) return 'N/A'

    const date = new Date(dateString)

    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  // Get the live type label
  const getLiveTypeLabel = callType => {
    switch (callType) {
      case 'video':
        return 'Video Call'
      case 'audio':
        return 'Audio Call'

      // case 3:
      //   return 'PK Battle'
      default:
        return 'Unknown'
    }
  }

  // Get the appropriate icon for live type
  const getLiveTypeIcon = (liveType, isAudio) => {
    switch (liveType) {
      case 'video':
        return 'tabler-video'
      case 'audio':
        return 'tabler-microphone'

      // case 3:
      //   return 'tabler-swords'
      default:
        return isAudio ? 'tabler-microphone' : 'tabler-video'
    }
  }

  // Get the appropriate color for live type
  const getLiveTypeColor = liveType => {
    switch (liveType) {
      case 'video':
        return 'success'
      case 'audio':
        return 'info'
      case 3:
        return 'error'
      default:
        return 'primary'
    }
  }

  // Generate a summary card for live stream data
  const getStreamSummary = () => {
    if (!liveStreams || liveStreams.length === 0) return null

    // Calculate total streams
    const totalStreams = history.total

    // Count by live type
    const liveTypeCounts = { 1: 0, 2: 0, 3: 0 }

    // Calculate total coins earned, gifts received, viewers, comments
    let totalCoins = 0
    let totalGifts = 0
    let totalViewers = 0
    let totalComments = 0

    liveStreams.forEach(stream => {
      // Increment type count
      if (stream.liveType) {
        liveTypeCounts[stream.liveType] = (liveTypeCounts[stream.liveType] || 0) + 1
      }

      // Add to totals
      totalCoins += stream.earnedCoins || 0
      totalGifts += stream.receivedGifts || 0
      totalViewers += stream.viewerCount || 0
      totalComments += stream.commentCount || 0
    })

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
                backgroundColor: 'primary.lightest',
                mr: 2
              }}
            >
              <i className='tabler-device-tv-old text-primary' style={{ fontSize: '1.5rem' }}></i>
            </Box>
            <Typography variant='h6'>Live Stream Summary</Typography>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Grid container spacing={3}>
            <Grid item xs={6} md={3}>
              <Typography variant='body2' color='text.secondary'>
                Total Streams
              </Typography>
              <Typography variant='h6' align='center'>
                {totalStreams}
              </Typography>
            </Grid>

            <Grid item xs={6} md={3}>
              <Typography variant='body2' color='text.secondary'>
                Total Coins Earned
              </Typography>
              <Typography variant='h6' align='center' color='success.main'>
                {totalCoins}
              </Typography>
            </Grid>

            <Grid item xs={6} md={3}>
              <Typography variant='body2' color='text.secondary'>
                Total Gifts Received
              </Typography>
              <Typography variant='h6' align='center' color='warning.main'>
                {totalGifts}
              </Typography>
            </Grid>

            <Grid item xs={6} md={3}>
              <Typography variant='body2' color='text.secondary'>
                Stream Types
              </Typography>
              <Box display='flex' flexWrap='wrap' gap={1} justifyContent='center' mt={1}>
                {liveTypeCounts[1] > 0 && (
                  <Chip
                    size='small'
                    icon={<i className='tabler-video'></i>}
                    label={`Video: ${liveTypeCounts[1]}`}
                    color='success'
                  />
                )}
                {liveTypeCounts[2] > 0 && (
                  <Chip
                    size='small'
                    icon={<i className='tabler-microphone'></i>}
                    label={`Audio: ${liveTypeCounts[2]}`}
                    color='info'
                  />
                )}
                {liveTypeCounts[3] > 0 && (
                  <Chip
                    size='small'
                    icon={<i className='tabler-swords'></i>}
                    label={`PK: ${liveTypeCounts[3]}`}
                    color='error'
                  />
                )}
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    )
  }

  const getAvatar = params => {
    const { avatar, fullName } = params

    if (avatar) {
      return <CustomAvatar src={avatar} size={40} className={'border-2 '} />
    } else {
      return <CustomAvatar size={40}>{getInitials(fullName)}</CustomAvatar>
    }
  }

  return (
    <>
      {/* Show summary if data exists */}
      {/* {!history.initialLoading && liveStreams.length > 0 && getStreamSummary()} */}

      {/* Live Stream History List */}
      {history.initialLoading ? (
        <Box>
          {[...Array(3)].map((_, index) => (
            <TransactionSkeleton key={index} />
          ))}
        </Box>
      ) : liveStreams.length > 0 ? (
        <Box>
          {liveStreams.map((stream, index) => {
            const liveTypeLabel = getLiveTypeLabel(stream.callType)
            const liveTypeIcon = getLiveTypeIcon(stream.callType, stream.isAudio)
            const liveTypeColor = getLiveTypeColor(stream.callType)

            return (
              <Paper
                key={`${stream._id}-${index}`}
                variant='outlined'
                sx={{
                  mb: 3,
                  borderRadius: 2,
                  overflow: 'hidden',
                  position: 'relative'
                }}
              >
                <Box p={3}>
                  {/* Header with live type and session ID */}
                  <Box display='flex' alignItems='center' mb={1}>
                    <Box
                      sx={{
                        display: 'flex',
                        alignItems: 'center',
                        color: `${liveTypeColor}.main`
                      }}
                    >
                      <i className={liveTypeIcon} style={{ fontSize: '1.25rem', marginRight: '8px' }}></i>
                      <Typography variant='subtitle1' fontWeight={600} color='inherit'>
                        {liveTypeLabel}
                      </Typography>
                    </Box>

                    {/* Duration badge */}

                    <Box display='flex' alignItems='center' ml='auto' sx={{ gap: 1 }}>
                      <Typography
                        variant='body2'
                        sx={{ fontWeight: 600 }}
                        color={stream.isIncome ? 'success.main' : 'error.main'}
                      >
                        {stream.isIncome ? '+' : '-'}
                        {stream.userCoin} Coins
                      </Typography>
                    </Box>
                  </Box>

                  <Box display='flex' gap={2} alignItems='center'>
                    <Typography variant='body2' color='text.secondary'>
                      Unique ID: {stream.uniqueId} | {formatDate(stream.createdAt)}
                    </Typography>
                    {/* <Typography variant='body2' color='text.secondary' mb={2}>
                    Call Time: {stream.date}
                  </Typography> */}

                    {stream.isRandom ? (
                      <Chip variant='tonal' label='Random' size='small' color='success' />
                    ) : (
                      <Chip variant='tonal' label='Private' size='small' color='error' />
                    )}
                  </Box>

                  {/* Start/End times */}
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
                      <Typography variant='body2'>{formatDate(stream.callStartTime)}</Typography>
                    </Box>
                    <Box textAlign='right'>
                      <Typography variant='caption' color='text.secondary' display='block'>
                        Ended
                      </Typography>
                      <Typography variant='body2'>{formatDate(stream.callEndTime)}</Typography>
                    </Box>
                  </Box>

                  <Box
                    display='flex'
                    justifyContent='space-between'
                    alignItems='flex-start'
                    gap={`2`}
                    sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
                  >
                    <div className='flex items-center gap-4 mr-1.5 w-full'>
                      {getAvatar({
                        avatar: getFullImageUrl(stream?.image),
                        fullName: stream?.name
                      })}
                      <Box>
                        <Typography variant='caption' color='text.secondary'>
                          Receiver
                        </Typography>
                        <Typography variant='body2'>{stream?.name || ' -'}</Typography>
                      </Box>
                    </div>
                    <div className='flex items-center gap-4 mr-1.5 w-full'>
                      <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                        <i className='tabler-phone-spark'></i>
                      </CustomAvatar>
                      <Box>
                        <Typography variant='caption' color='text.secondary'>
                          Call Status
                        </Typography>
                        <Typography variant='body2'>{stream?.callStatusText || ' -'}</Typography>
                      </Box>
                    </div>
                  </Box>
                  <Box
                    display='flex'
                    justifyContent='space-between'
                    alignItems='flex-start'
                    gap={`2`}
                    sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
                  >
                    <div className='flex items-center gap-4 mr-1.5 w-full'>
                      <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                        <i className='tabler-clock-12'></i>
                      </CustomAvatar>
                      <Box>
                        <Typography variant='caption' color='text.secondary'>
                          Duration
                        </Typography>
                        <Typography variant='body2'>{formatDuration(stream.duration)}</Typography>
                      </Box>
                    </div>
                    <div className='flex items-center gap-4 mr-1.5 w-full'>
                      <CustomAvatar skin='light' color='error' size='sm' sx={{ mr: 1.5 }}>
                        <i className='tabler-crown'></i>
                      </CustomAvatar>
                      <Box>
                        <Typography variant='caption' color='text.secondary'>
                          Caller Role
                        </Typography>
                        <Typography variant='body2'>{stream?.callerRole || ' -'}</Typography>
                      </Box>
                    </div>
                  </Box>
                  <Box
                    display='flex'
                    alignItems='flex-start'
                    gap={2}

                    // sx={{ borderBottom: '1px solid', borderColor: 'divider', pb: 2, mb: 2 }}
                  >
                    <Chip variant='tonal' label={`User : ${stream?.userCoin || '0'} Coins`} size='small' color='info' />

                    <Chip
                      variant='tonal'
                      label={`Listener : ${stream?.listenerCoin || '0'} Coins`}
                      size='small'
                      color='success'
                    />
                    <Chip
                      variant='tonal'
                      label={`Admin : ${stream?.adminCoin || '0'} Coins`}
                      size='small'
                      color='warning'
                    />
                  </Box>
                </Box>
              </Paper>
            )
          })}

          {/* Loader for infinite scroll */}
          {/* {history.hasMore && (
            <Box ref={ref} display='flex' justifyContent='center' py={2}>
              {history.loading ? (
                <CircularProgress size={40} thickness={4} />
              ) : (
                <Typography variant='body2' color='text.secondary'>
                  Scroll to load more
                </Typography>
              )}
            </Box>
          )} */}
        </Box>
      ) : (
        <EmptyState
          icon='tabler-video-off'
          title='No Live Stream History'
          description="This user hasn't streamed yet or no records are available."
        />
      )}
    </>
  )
}

export default LiveStreamTab
