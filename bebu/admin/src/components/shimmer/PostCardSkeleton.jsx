import React from 'react'

import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CardActions from '@mui/material/CardActions'
import Skeleton from '@mui/material/Skeleton'
import Box from '@mui/material/Box'
import Divider from '@mui/material/Divider'

const PostCardSkeleton = () => {
  return (
    <Card className='h-full flex flex-col shadow-md' sx={{ borderRadius: '12px', overflow: 'hidden' }}>
      <Box sx={{ p: 2 }} className='flex gap-2'>
        <Skeleton variant='circular' width={40} height={40} />
        <Box className='flex-1'>
          <Skeleton variant='text' width='70%' height={24} />
          <Skeleton variant='text' width='40%' height={20} />
        </Box>
        <Skeleton variant='circular' width={30} height={30} />
      </Box>
      <Skeleton variant='rectangular' height={280} className='w-full' />
      <CardContent className='py-3'>
        <Skeleton variant='text' width='100%' height={20} />
        <Skeleton variant='text' width='90%' height={20} />
        <Box sx={{ mt: 2 }} className='flex gap-1'>
          <Skeleton variant='rounded' width={60} height={24} />
          <Skeleton variant='rounded' width={80} height={24} />
        </Box>
      </CardContent>
      <Divider />
      <CardActions disableSpacing className='px-3 py-2'>
        <Box className='w-full flex justify-between'>
          <Box className='flex gap-3'>
            <Box className='flex items-center'>
              <Skeleton variant='circular' width={30} height={30} sx={{ mr: 0.5 }} />
              <Skeleton variant='text' width={15} height={20} />
            </Box>
            <Box className='flex items-center'>
              <Skeleton variant='circular' width={30} height={30} sx={{ mr: 0.5 }} />
              <Skeleton variant='text' width={15} height={20} />
            </Box>
          </Box>
          <Skeleton variant='text' width={70} height={20} />
        </Box>
      </CardActions>
    </Card>
  )
}

export default PostCardSkeleton
