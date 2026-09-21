'use client'

import { useState, useRef, useEffect } from 'react'

import Image from 'next/image'

import { useDispatch } from 'react-redux'
import { format } from 'date-fns'
import { Swiper, SwiperSlide } from 'swiper/react'
import { Pagination, Navigation, Autoplay } from 'swiper/modules'

// Import Swiper styles
import 'swiper/css'
import 'swiper/css/pagination'
import 'swiper/css/navigation'

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

// Component Import
import ConfirmationDialog from './dialogs/confirmation-dialog'
import SocialDrawer from './drawers/social-drawer'

// Action Imports
import { deletePost } from '@/redux-store/slices/posts'
import { getFullImageUrl } from '@/utils/commonfunctions'

const PostCard = ({ post, onEdit, isFakePost }) => {
  const [anchorEl, setAnchorEl] = useState(null)
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false)
  const [loading, setLoading] = useState(false)
  const [deleteError, setDeleteError] = useState(null)
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
    onEdit(post)
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
      const resultAction = await dispatch(deletePost(post._id))

      if (deletePost.rejected.match(resultAction)) {
        setDeleteError(resultAction.payload || 'Failed to delete post')
      }
    } catch (error) {
      setDeleteError(error.message || 'Failed to delete post')
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

  return (
    <>
      <Card
        className='h-full flex flex-col shadow-md hover:shadow-lg transition-all duration-300'
        sx={{ borderRadius: '12px', overflow: 'hidden', position: 'relative' }}
      >
        <CardHeader
          avatar={
            <Avatar
              src={getFullImageUrl(post.userImage || post.userId.image)}
              sx={{ boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}
            />
          }
          action={
            <IconButton aria-label='settings' onClick={handleMenuOpen}>
              <MoreVertIcon />
            </IconButton>
          }
          title={
            <Typography variant='subtitle1' sx={{ fontWeight: 600 }}>
              {post.name || post.userId.name || 'Anonymous'}
            </Typography>
          }
          subheader={
            <Typography variant='body2' color='text.secondary'>
              {post.userName || post.userId.userName}
            </Typography>
          }
        />
        <div className='relative h-[280px] overflow-hidden'>
          {post.postImage && post.postImage.length > 0 ? (
            <Swiper
              modules={[Pagination, Navigation, Autoplay]}
              pagination={{ clickable: true }}
              navigation={post.postImage.length > 1}
              autoplay={post.postImage.length > 1 ? { delay: 5000, disableOnInteraction: false } : false}
              className='h-full swiper-custom'
            >
              {post.postImage.map((image, index) => (
                <SwiperSlide key={`${post._id}-image-${index}`} className='flex items-center justify-center bg-gray-50'>
                  <img
                    src={getFullImageUrl(image.url)}
                    alt={`Post by ${post.name || 'Anonymous'}`}
                    className='h-full w-full object-cover'
                    style={{ maxHeight: '280px' }}
                    loading='lazy'
                    onError={e => {
                      e.target.src = '/images/avatars/placeholder-image.webp'
                    }}
                  />
                </SwiperSlide>
              ))}
            </Swiper>
          ) : (
            <Box className='h-[280px] w-full flex items-center justify-center bg-gray-100'>
              <Typography variant='body2' color='text.secondary'>
                No image
              </Typography>
            </Box>
          )}
        </div>
        {post.caption || (post.hashTags && post.hashTags.length > 0) ? (
          <CardContent className='py-3 flex flex-wrap'>
            {post.caption && (
              <Typography variant='body2' color='text.primary' className='mr-2'>
                {post.caption}
              </Typography>
            )}
            {post.hashTags && post.hashTags.length > 0 && (
              <Box className='flex flex-wrap gap-1'>
                {post.hashTags.map(tag => (
                  <Typography variant='body2' color='text.primary' key={`${post._id}-tag-${tag._id}`}>
                    {tag.hashTag}
                  </Typography>
                ))}
              </Box>
            )}
          </CardContent>
        ) : (
          <CardContent className='py-3 flex'>
            <Typography variant='body2' color='text.primary'>
              No caption or hash tags
            </Typography>
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
                {post.totalLikes || 0}
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
                {post.totalComments || 0}
              </Typography>
            </Box>
          </Box>
          <Box className='flex items-center'>
            <AccessTimeIcon fontSize='small' color='action' sx={{ mr: 1, fontSize: '16px' }} />
            <Typography variant='caption' color='text.secondary'>
              {formatDate(post.createdAt).split(' ').slice(0, 3).join(' ')}
            </Typography>
          </Box>
        </CardActions>
      </Card>

      <style jsx global>{`
        .swiper-custom .swiper-pagination-bullet {
          background-color: white;
          opacity: 0.8;
          width: 6px;
          height: 6px;
        }
        .swiper-custom .swiper-pagination-bullet-active {
          opacity: 1;
          background-color: white;
        }
        .swiper-custom .swiper-button-next,
        .swiper-custom .swiper-button-prev {
          color: white;
          background-color: rgba(0, 0, 0, 0.3);
          width: 20px !important;
          height: 20px !important;
          border-radius: 50%;
        }
        .swiper-custom .swiper-button-next:after,
        .swiper-custom .swiper-button-prev:after {
          font-size: 8px !important;
          font-weight: bold;
        }
        .swiper-custom .swiper-button-next:hover,
        .swiper-custom .swiper-button-prev:hover {
          background-color: rgba(0, 0, 0, 0.6);
        }
        .swiper-custom .swiper-button-next {
          right: 5px;
        }
        .swiper-custom .swiper-button-prev {
          left: 5px;
        }
      `}</style>

      {/* Card Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
        transformOrigin={{ horizontal: 'right', vertical: 'top' }}
        anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
      >
        <MenuItem key='edit' onClick={handleEdit}>
          <EditOutlinedIcon fontSize='small' className='mr-2' />
          Edit
        </MenuItem>
        <MenuItem key='delete' onClick={handleDelete}>
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
        title='Delete Post'
        content='Are you sure you want to delete this post? This action cannot be undone.'
        loading={loading}
        error={deleteError}
        type='delete-post'
      />

      {/* Social Drawer */}
      <SocialDrawer
        open={drawerOpen}
        onClose={handleCloseDrawer}
        type='post'
        itemId={post._id}
        drawerType={drawerType}
      />
    </>
  )
}

export default PostCard
