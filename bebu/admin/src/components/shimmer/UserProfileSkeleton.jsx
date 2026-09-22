'use client'

import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Box from '@mui/material/Box'
import Stack from '@mui/material/Stack'

import Skeleton from './Skeleton'

// Left section components
const UserDetailsSkeleton = () => {
  return (
    <Card>
      <CardContent className='flex flex-col pbs-12 gap-6'>
        {/* User Avatar and Info */}
        <div className='flex flex-col gap-6'>
          <div className='flex items-center justify-center flex-col gap-4'>
            <Skeleton variant='rounded' width={120} height={120} />
            <Skeleton width={150} height={24} />
          </div>
          <Skeleton width={80} height={24} sx={{ alignSelf: 'center' }} />

          {/* Stats Cards */}
          <div className='flex items-center justify-evenly flex-wrap gap-4'>
            <div className='flex items-center gap-4'>
              <Skeleton variant='rounded' width={40} height={40} />
              <div>
                <Skeleton width={60} height={20} />
                <Skeleton width={100} height={16} sx={{ mt: 1 }} />
              </div>
            </div>
            <div className='flex items-center gap-4'>
              <Skeleton variant='rounded' width={40} height={40} />
              <div>
                <Skeleton width={60} height={20} />
                <Skeleton width={100} height={16} sx={{ mt: 1 }} />
              </div>
            </div>
          </div>
        </div>

        {/* Details Section */}
        <div>
          <Skeleton width={80} height={24} sx={{ mb: 2 }} />
          <Skeleton width='100%' height={1} sx={{ mb: 3 }} />

          <Stack spacing={2}>
            {[...Array(6)].map((_, index) => (
              <div key={index} className='flex items-center flex-wrap gap-x-1.5'>
                <Skeleton width={60} height={18} />
                <Skeleton width={150} height={18} />
              </div>
            ))}
          </Stack>
        </div>
      </CardContent>
    </Card>
  )
}

const UserPlanSkeleton = () => {
  return (
    <Card className='border-2 border-primary rounded'>
      <CardContent className='flex flex-col gap-6'>
        <div className='flex justify-between items-center'>
          <div className='flex items-center gap-3'>
            <Skeleton variant='rounded' width={40} height={40} />
            <div>
              <Skeleton width={80} height={20} />
              <Skeleton width={50} height={16} sx={{ mt: 0.5 }} />
            </div>
          </div>
          <Skeleton width={60} height={24} />
        </div>

        <Stack spacing={2}>
          {[...Array(3)].map((_, index) => (
            <div key={index} className='flex items-center gap-2'>
              <Skeleton variant='circular' width={10} height={10} />
              <Skeleton width={200} height={16} />
            </div>
          ))}
        </Stack>

        <div>
          <div className='flex items-center justify-between mb-1'>
            <Skeleton width={120} height={16} />
            <Skeleton width={80} height={16} />
          </div>
          <Skeleton width='100%' height={4} />
          <div className='flex justify-between mt-1'>
            <Skeleton width={100} height={16} />
            <Skeleton width={100} height={16} />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

// Right section components
const TabListSkeleton = () => {
  return (
    <div className='flex overflow-x-auto pb-2'>
      {[...Array(2)].map((_, index) => (
        <Skeleton key={index} width={120} height={40} variant='rounded' sx={{ mr: 2, flexShrink: 0 }} />
      ))}
    </div>
  )
}

const InfoCardSkeleton = () => {
  return (
    <Card>
      <CardContent>
        <Skeleton width={180} height={24} sx={{ mb: 2 }} />
        <Skeleton width='100%' height={1} sx={{ mb: 4 }} />

        <Grid container spacing={4}>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              {[...Array(4)].map((_, index) => (
                <div key={index}>
                  <Skeleton width={100} height={16} sx={{ mb: 1 }} />
                  <Skeleton width={180} height={20} />
                </div>
              ))}
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              {[...Array(4)].map((_, index) => (
                <div key={index}>
                  <Skeleton width={100} height={16} sx={{ mb: 1 }} />
                  <Skeleton width={180} height={20} />
                </div>
              ))}
            </Stack>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  )
}

const WealthLevelCardSkeleton = () => {
  return (
    <Card>
      <CardContent>
        <Skeleton width={180} height={24} sx={{ mb: 2 }} />
        <Skeleton width='100%' height={1} sx={{ mb: 4 }} />

        <Grid container spacing={4}>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              <div className='flex items-center gap-3'>
                <Skeleton variant='rounded' width={40} height={40} />
                <div>
                  <Skeleton width={100} height={16} sx={{ mb: 1 }} />
                  <Skeleton width={80} height={20} />
                </div>
              </div>
              {[...Array(2)].map((_, index) => (
                <div key={index}>
                  <Skeleton width={100} height={16} sx={{ mb: 1 }} />
                  <Skeleton width={120} height={20} />
                </div>
              ))}
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              {[...Array(3)].map((_, index) => (
                <div key={index}>
                  <Skeleton width={100} height={16} sx={{ mb: 1 }} />
                  <Skeleton width={120} height={20} />
                </div>
              ))}
            </Stack>
          </Grid>
        </Grid>

        <Skeleton width='100%' height={1} sx={{ my: 4 }} />

        <Skeleton width={120} height={20} sx={{ mb: 2 }} />
        <div className='flex items-center gap-3'>
          <Skeleton variant='rounded' width={60} height={60} />
          <div>
            <Skeleton width={150} height={20} sx={{ mb: 1 }} />
            <Skeleton width={200} height={16} />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

const StatusCardSkeleton = () => {
  return (
    <Card>
      <CardContent>
        <Skeleton width={180} height={24} sx={{ mb: 2 }} />
        <Skeleton width='100%' height={1} sx={{ mb: 4 }} />

        <Grid container spacing={4}>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              {[...Array(2)].map((_, index) => (
                <div key={index} className='flex items-center gap-2'>
                  <Skeleton width={100} height={16} />
                  <Skeleton width={80} height={24} variant='rounded' />
                </div>
              ))}
            </Stack>
          </Grid>
          <Grid size={{ xs: 12, md: 6 }}>
            <Stack spacing={3}>
              {[...Array(2)].map((_, index) => (
                <div key={index} className='flex items-center gap-2'>
                  <Skeleton width={100} height={16} />
                  <Skeleton width={80} height={24} variant='rounded' />
                </div>
              ))}
            </Stack>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  )
}

// Main User Profile Skeleton
const UserProfileSkeleton = () => {
  return (
    <Grid container spacing={6}>
      {/* Left Section */}
      <Grid size={{ xs: 12, lg: 4, md: 5 }}>
        <Grid container spacing={6}>
          <Grid size={{ xs: 12 }}>
            <UserDetailsSkeleton />
          </Grid>
          <Grid size={{ xs: 12 }}>
            <UserPlanSkeleton />
          </Grid>
        </Grid>
      </Grid>

      {/* Right Section */}
      <Grid size={{ xs: 12, lg: 8, md: 7 }}>
        <Grid container spacing={6}>
          <Grid size={{ xs: 12 }}>
            <TabListSkeleton />
          </Grid>
          <Grid size={{ xs: 12 }}>
            <Stack spacing={6}>
              <InfoCardSkeleton />
              <WealthLevelCardSkeleton />
              <StatusCardSkeleton />
            </Stack>
          </Grid>
        </Grid>
      </Grid>
    </Grid>
  )
}

export default UserProfileSkeleton
