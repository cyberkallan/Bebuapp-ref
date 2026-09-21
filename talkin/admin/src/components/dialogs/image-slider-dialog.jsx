import React, { useState, forwardRef } from 'react'

// MUI Imports
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import IconButton from '@mui/material/IconButton'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Slide from '@mui/material/Slide'
import { styled } from '@mui/material/styles'
import Divider from '@mui/material/Divider'
import Chip from '@mui/material/Chip'
import Avatar from '@mui/material/Avatar'

// Swiper Imports
import { Swiper, SwiperSlide } from 'swiper/react'
import { Pagination, Navigation, Autoplay } from 'swiper/modules'

// Import Swiper styles
import 'swiper/css'
import 'swiper/css/pagination'
import 'swiper/css/navigation'

// Icons
import CloseIcon from '@mui/icons-material/Close'
import FavoriteIcon from '@mui/icons-material/Favorite'
import CommentIcon from '@mui/icons-material/Comment'
import ShareIcon from '@mui/icons-material/Share'

// Utils
import { getFullImageUrl } from '@/utils/commonfunctions'

// Component Imports
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'

// Styled component for the image container
const ImageContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  height: '60vh',
  overflow: 'hidden',
  backgroundColor: theme.palette.grey[100]
}))

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const ImageSliderDialog = ({ open, onClose, images, postData }) => {
  if (!postData || !open) return null

  return (
    <Dialog
      open={open}
      onClose={onClose}
      fullWidth
      maxWidth='md'
      TransitionComponent={Transition}
      PaperProps={{
        sx: {
          borderRadius: '12px',
          overflow: 'visible',
          width: '600px',
          maxWidth: '95vw'
        }
      }}
    >
      <DialogTitle>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Avatar src={getFullImageUrl(postData?.userImage)} alt={postData?.name} sx={{ width: 40, height: 40 }} />
            <Box>
              <Typography variant='subtitle1'>{postData?.name}</Typography>
              <Typography variant='caption' color='text.secondary'>
                {postData?.userName}
              </Typography>
            </Box>
          </Box>
        </Box>
        <DialogCloseButton onClick={onClose}>
          <CloseIcon />
        </DialogCloseButton>
      </DialogTitle>

      <Divider />

      <DialogContent sx={{ p: 0, position: 'relative' }}>
        {/* Image Slider */}
        <ImageContainer>
          {images && images.length > 0 ? (
            <Swiper
              modules={[Pagination, Navigation, Autoplay]}
              pagination={{ clickable: true }}
              navigation={images.length > 1}
              autoplay={images.length > 1 ? { delay: 5000, disableOnInteraction: false } : false}
              className='h-full w-full swiper-custom'
            >
              {images.map((image, index) => (
                <SwiperSlide key={`slide-${index}`} className='flex items-center justify-center'>
                  <img
                    src={getFullImageUrl(image.url)}
                    alt={`Post image ${index + 1}`}
                    className='h-full w-full object-cover'
                    style={{ maxHeight: '60vh' }}
                  />
                </SwiperSlide>
              ))}
            </Swiper>
          ) : (
            <Box className='h-full w-full flex items-center justify-center'>
              <Typography variant='body2' color='text.secondary'>
                No images available
              </Typography>
            </Box>
          )}
        </ImageContainer>

        {/* Post Caption and Hashtags */}
        <Box sx={{ p: 3 }}>
          <Typography variant='body1'>{postData?.caption}</Typography>

          {postData?.mentionedUsers && postData.mentionedUsers.length > 0 && (
            <Box className='flex flex-wrap gap-1 mb-2'>
              {postData.mentionedUsers.map(user => (
                <Typography key={user._id} variant='body2'>
                  {user.userName.startsWith('@') ? user.name : `@${user.name}`}
                </Typography>
              ))}
            </Box>
          )}

          {/* Hashtags */}
          {postData?.hashTags && postData.hashTags.length > 0 && (
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mt: 2 }}>
              {postData.hashTags.map(tag => (
                <Chip key={tag._id} label={tag.hashTag} size='small' color='primary' variant='outlined' />
              ))}
            </Box>
          )}

          {/* Interaction Stats */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mt: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <FavoriteIcon color='error' fontSize='small' />
              <Typography variant='body2'>{postData?.totalLikes || 0} likes</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <CommentIcon fontSize='small' />
              <Typography variant='body2'>{postData?.totalComments || 0} comments</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <ShareIcon fontSize='small' />
              <Typography variant='body2'>{postData?.shareCount || 0} shares</Typography>
            </Box>
          </Box>

          {/* Post date */}
          <Typography variant='caption' color='text.secondary' sx={{ display: 'block', mt: 2 }}>
            Posted on:{' '}
            {postData?.createdAt
              ? new Date(postData.createdAt).toLocaleDateString('en-US', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })
              : 'Unknown date'}
          </Typography>
        </Box>
      </DialogContent>

      <style jsx global>{`
        .swiper-custom .swiper-pagination-bullet {
          background-color: #1976d2;
          opacity: 0.8;
          width: 6px;
          height: 6px;
        }
        .swiper-custom .swiper-pagination-bullet-active {
          opacity: 1;
          background-color: #1976d2;
        }
        .swiper-custom .swiper-button-next,
        .swiper-custom .swiper-button-prev {
          color: white;
          background-color: rgba(0, 0, 0, 0.3);
          width: 30px !important;
          height: 30px !important;
          border-radius: 50%;
        }
        .swiper-custom .swiper-button-next:after,
        .swiper-custom .swiper-button-prev:after {
          font-size: 12px !important;
          font-weight: bold;
        }
        .swiper-custom .swiper-button-next:hover,
        .swiper-custom .swiper-button-prev:hover {
          background-color: rgba(0, 0, 0, 0.6);
        }
        .swiper-custom .swiper-button-next {
          right: 10px;
        }
        .swiper-custom .swiper-button-prev {
          left: 10px;
        }
      `}</style>
    </Dialog>
  )
}

export default ImageSliderDialog
