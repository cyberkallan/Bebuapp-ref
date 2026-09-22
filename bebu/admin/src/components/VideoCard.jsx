'use client'

import { useState, useRef, useEffect } from 'react'

import { useDispatch } from 'react-redux'
import { format } from 'date-fns'

// MUI Imports
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardMedia from '@mui/material/CardMedia'
import CardContent from '@mui/material/CardContent'
import CardActions from '@mui/material/CardActions'
import IconButton from '@mui/material/IconButton'
import Typography from '@mui/material/Typography'
import Avatar from '@mui/material/Avatar'
import Menu from '@mui/material/Menu'
import MenuItem from '@mui/material/MenuItem'
import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Badge from '@mui/material/Badge'
import Divider from '@mui/material/Divider'
import Tooltip from '@mui/material/Tooltip'

// Icon Imports
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined'
import CommentOutlinedIcon from '@mui/icons-material/CommentOutlined'
import MoreVertIcon from '@mui/icons-material/MoreVert'
import EditOutlinedIcon from '@mui/icons-material/EditOutlined'
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline'
import AccessTimeIcon from '@mui/icons-material/AccessTime'
import FakeIcon from '@mui/icons-material/SentimentVeryDissatisfied'
import RealIcon from '@mui/icons-material/Verified'
import VideocamIcon from '@mui/icons-material/Videocam'

// Component Import
import ConfirmationDialog from './dialogs/confirmation-dialog'
import SocialDrawer from './drawers/social-drawer'

// Action Imports
import { deleteVideo } from '@/redux-store/slices/videos'
import { getFullImageUrl } from '@/utils/commonfunctions'

const VideoCard = ({ video, onEdit, isFakeVideo }) => {
  const [anchorEl, setAnchorEl] = useState(null)
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false)
  const [loading, setLoading] = useState(false)
  const [deleteError, setDeleteError] = useState(null)
  const [isPlaying, setIsPlaying] = useState(false)
  const videoRef = useRef(null)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [drawerType, setDrawerType] = useState(null)
  const dispatch = useDispatch()

  const handleMenuOpen = event => {
    setAnchorEl(event.currentTarget)
  }

  const handleMenuClose = () => {
    setAnchorEl(null)
  }

  const handleEdit = () => {
    handleMenuClose()
    onEdit(video)
  }

  const handleDelete = () => {
    handleMenuClose()
    setDeleteError(null)
    setConfirmDialogOpen(true)
  }

  const handleOpenDrawer = type => {
    setDrawerType(type)
    setDrawerOpen(true)
  }

  const handleCloseDrawer = () => {
    setDrawerOpen(false)
    setDrawerType(null)
  }

  const confirmDelete = async () => {
    setLoading(true)
    setDeleteError(null)

    try {
      const resultAction = await dispatch(deleteVideo({ userId: video.userId._id, videoId: video._id }))

      if (deleteVideo.rejected.match(resultAction)) {
        setDeleteError(resultAction.payload || 'Failed to delete video')
      }
    } catch (error) {
      setDeleteError(error.message || 'Failed to delete video')
    }

    setLoading(false)
  }

  const formatDate = dateString => {
    try {
      const date = new Date(dateString)

      return format(date, 'MMM dd, yyyy h:mm a')
    } catch (error) {
      return dateString
    }
  }

  const formatDuration = seconds => {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60

    return `${minutes}:${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`
  }

  const handleVideoToggle = () => {
    if (videoRef.current) {
      if (isPlaying) {
        videoRef.current.pause()
      } else {
        videoRef.current.play()
      }

      setIsPlaying(!isPlaying)
    }
  }

  return (
    <>
      <Card
        className='h-full flex flex-col shadow-md hover:shadow-lg transition-all duration-300'
        sx={{ borderRadius: '12px', overflow: 'hidden', position: 'relative' }}
      >
        <CardHeader
          avatar={
            <Avatar
              src={`${baseURL}/${video.userImage || video.userId.image}`}
              sx={{ boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}
            >
              {video.name ? video.name?.charAt(0) : 'U'}
            </Avatar>
          }
          action={
            <IconButton aria-label='settings' onClick={handleMenuOpen}>
              <MoreVertIcon />
            </IconButton>
          }
          title={
            <Typography variant='subtitle1' sx={{ fontWeight: 600 }}>
              {video.name || video.userId.name || 'Anonymous'}
            </Typography>
          }
          subheader={
            <Typography variant='body2' color='text.secondary'>
              {video.userName || video.userId.userName}
            </Typography>
          }
        />
        <div className='relative h-[280px] overflow-hidden bg-gray-900'>
          {video.videoUrl && (
            <div className='relative h-full w-full'>
              <video
                ref={videoRef}
                src={getFullImageUrl(video.videoUrl)}
                poster={getFullImageUrl(video.videoImage)}
                className='h-full w-full object-contain'
                onClick={handleVideoToggle}
                style={{ cursor: 'pointer' }}
                playsInline
                onPlay={() => setIsPlaying(true)}
                onPause={() => setIsPlaying(false)}
              />
              {!isPlaying && (
                <Box
                  className='absolute inset-0 flex items-center justify-center'
                  onClick={handleVideoToggle}
                  sx={{
                    cursor: 'pointer',
                    background: 'rgba(0, 0, 0, 0.3)',
                    transition: 'all 0.2s'
                  }}
                >
                  <IconButton
                    sx={{
                      backgroundColor: 'rgba(255, 255, 255, 0.2)',
                      '&:hover': { backgroundColor: 'rgba(255, 255, 255, 0.3)' }
                    }}
                  >
                    <VideocamIcon sx={{ color: 'white', fontSize: '2rem' }} />
                  </IconButton>
                </Box>
              )}
              <Box className='absolute top-2 right-2 px-2 py-1 rounded' sx={{ backgroundColor: 'rgba(0, 0, 0, 0.6)' }}>
                <Typography variant='caption' sx={{ color: 'white' }}>
                  {formatDuration(video.videoTime)}
                </Typography>
              </Box>
            </div>
          )}
        </div>
        {(video.caption || video.hashTags?.length > 0 || video.mentionedUsers?.length > 0) && (
          <CardContent className='py-3'>
            {video.caption && (
              <Typography
                variant='body2'
                color='text.primary'
                sx={{ mb: video.hashTags?.length > 0 || video.mentionedUsers?.length > 0 ? 2 : 0 }}
              >
                caption: {video.caption}
              </Typography>
            )}

            {video.hashTags?.length > 0 || video.mentionedUsers?.length > 0 ? (
              <div className='flex justify-between'>
                <Box className='flex gap-1'>
                  {video.hashTags?.map(tag => (
                    <Typography
                      key={`${video._id}-tag-${tag._id}`}
                      variant='body2'
                      color='text.primary'
                      className='text-xs'
                    >
                      {tag.hashTag}
                    </Typography>
                  ))}
                </Box>
                <Box className='flex flex-wrap gap-1 mt-1'>
                  {video.mentionedUsers?.map(user => (
                    <Typography
                      key={`${video._id}-mention-${user._id}`}
                      variant='body2'
                      color='text.primary'
                      className='text-xs'
                    >
                      @{user.name}
                    </Typography>
                  ))}
                </Box>
              </div>
            ) : (
              <Typography variant='body2' color='text.primary'>
                No hash tags or mentioned users
              </Typography>
            )}
          </CardContent>
        )}

        <Divider />
        <CardActions disableSpacing className='px-3 py-2 flex justify-between'>
          <Box className='flex gap-3'>
            <Box className='flex items-center'>
              <IconButton aria-label='likes' size='small' sx={{ mr: 0.5 }} onClick={() => handleOpenDrawer('likes')}>
                <ThumbUpOutlinedIcon fontSize='small' />
              </IconButton>
              <Typography variant='body2' color='text.secondary'>
                {video.totalLikes || 0}
              </Typography>
            </Box>
            <Box className='flex items-center'>
              <IconButton
                aria-label='comments'
                size='small'
                sx={{ mr: 0.5 }}
                onClick={() => handleOpenDrawer('comments')}
              >
                <CommentOutlinedIcon fontSize='small' />
              </IconButton>
              <Typography variant='body2' color='text.secondary'>
                {video.totalComments || 0}
              </Typography>
            </Box>
          </Box>
          <Box className='flex items-center'>
            <AccessTimeIcon fontSize='small' color='action' sx={{ mr: 1, fontSize: '16px' }} />
            <Typography variant='caption' color='text.secondary'>
              {formatDate(video.createdAt).split(' ').slice(0, 3).join(' ')}
            </Typography>
          </Box>
        </CardActions>
      </Card>

      {/* Card Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
        transformOrigin={{ horizontal: 'right', vertical: 'top' }}
        anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
      >
        <MenuItem onClick={handleEdit}>
          <EditOutlinedIcon fontSize='small' className='mr-2' />
          Edit
        </MenuItem>
        <MenuItem onClick={handleDelete}>
          <DeleteOutlineIcon fontSize='small' className='mr-2' />
          Delete
        </MenuItem>
      </Menu>

      {/* Confirmation Dialog */}
      <ConfirmationDialog
        open={confirmDialogOpen}
        onClose={() => {
          setConfirmDialogOpen(false)
          setDeleteError(null)
        }}
        onConfirm={confirmDelete}
        title='Delete Video'
        content='Are you sure you want to delete this video? This action cannot be undone.'
        loading={loading}
        error={deleteError}
        type='delete-video'
      />

      {/* Social Drawer */}
      <SocialDrawer
        open={drawerOpen}
        onClose={handleCloseDrawer}
        type='video'
        itemId={video._id}
        drawerType={drawerType}
      />
    </>
  )
}

export default VideoCard
