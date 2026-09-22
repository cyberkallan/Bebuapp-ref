'use client'

import { forwardRef, useEffect } from 'react'

import { Box, Chip, Dialog, DialogContent, Divider, Grid, Slide, Typography } from '@mui/material'

import CustomAvatar from '@/@core/components/mui/Avatar'
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'
import { getFullImageUrl } from '@/utils/commonfunctions'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const ReqViewDialog = ({ open, onClose, data }) => {
  useEffect(() => {
    console.log('data--->', data)
  }, [data])

  return (
    <Dialog
      open={open}
      keepMounted
      onClose={onClose}
      TransitionComponent={Transition}
      closeAfterTransition={false}
      fullWidth
      PaperProps={{
        sx: {
          overflow: 'visible',
          maxWidth: '650px'
        }
      }}
    >
      {/* <Paper sx={{ position: 'relative', p: 0 }}> */}
      <DialogCloseButton onClick={onClose}>
        <i className='tabler-x' />
      </DialogCloseButton>

      <DialogContent sx={{ p: 0 }}>
        <Box>
          {/* Header with Avatar and basic info */}
          <Box sx={{ p: 4, pb: 3, display: 'flex', alignItems: 'center', gap: 3 }}>
            <CustomAvatar
              alt={data?.name || data?.userId?.fullName || 'User'}
              src={getFullImageUrl(data?.userId?.profilePic)}
              skin='light'
              color='primary'
              variant='circular'
              size={60}
            >
              {(data?.name || data?.userId?.fullName || 'U').charAt(0)}
            </CustomAvatar>
            <Box>
              <div className='flex justify-center items-center gap-2'>
                <Typography variant='h5'>{data?.userId?.fullName}</Typography>({' '}
                <Typography variant='p'>{data?.userId?.nickName || '-'}</Typography>)
              </div>
              <Typography variant='body2' color='text.secondary'>
                ID: {data?.userId?.uniqueId}
              </Typography>
              <Typography variant='body2' color='text.secondary'>
                Gender: {data?.userId?.gender}
              </Typography>
            </Box>
          </Box>

          <Divider />

          {/* Contact Information Section */}
          <Box sx={{ p: 4, pb: 3 }}>
            <Typography variant='h6' sx={{ mb: 3, display: 'flex', alignItems: 'center' }}>
              Listener Information
            </Typography>

            <Grid container spacing={2}>
              <Grid size={6}>
                <Box>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Email
                  </Typography>
                  <Typography variant='body1'>{data?.email}</Typography>
                </Box>
              </Grid>

              <Grid size={6}>
                <Box>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Full name
                  </Typography>
                  <Typography variant='body1'>{data?.name}</Typography>
                </Box>
              </Grid>
              <Grid size={6}>
                <Box>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Nickname
                  </Typography>
                  <Typography variant='body1'>{data?.nickName || '-'}</Typography>
                </Box>
              </Grid>
              <Grid size={6}>
                <Box>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Experience
                  </Typography>
                  <Typography variant='body1'>{data?.experience || '0'}</Typography>
                </Box>
              </Grid>
            </Grid>
          </Box>

          <Divider />

          {/* About Section */}
          <Box sx={{ p: 4, pb: 3 }}>
            <Typography variant='h6' sx={{ mb: 3, display: 'flex', alignItems: 'center' }}>
              {/* <i className='tabler-info-circle me-2' style={{ fontSize: '1rem' }} /> */}
              Bio
            </Typography>
            <Typography variant='body1'>{data?.selfIntro}</Typography>
          </Box>

          {data?.reason ? (
            <Box sx={{ p: 4, pb: 3 }}>
              <Typography variant='h6' sx={{ mb: 3, display: 'flex', alignItems: 'center' }}>
                Reject Reason
              </Typography>
              <Typography variant='body1'>{data?.reason || '-'}</Typography>
            </Box>
          ) : null}

          <Divider />

          <Box sx={{ p: 4, pb: 3 }}>
            <Typography variant='h6' sx={{ mb: 3, display: 'flex', alignItems: 'center' }}>
              {/* <i className='tabler-address-book me-2' style={{ fontSize: '1rem' }} /> */}
              Additional Information
            </Typography>

            <Grid container spacing={2}>
              <Grid size={6}>
                {/* <i className='tabler-mail' style={{ color: 'text.secondary' }} /> */}
                <Box sx={{ mb: 3 }}>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Talk Topics
                  </Typography>
                  <Box sx={{ mt: 1 }}>
                    {data?.talkTopics && data?.talkTopics.length > 0 ? (
                      data.talkTopics.map((item, i) => (
                        <Chip
                          key={i}
                          label={item}
                          size='small'
                          variant='outlined'
                          sx={{ mr: 1, mb: 1, borderRadius: '16px' }}
                        />
                      ))
                    ) : (
                      <Typography variant='body2'>-</Typography>
                    )}
                  </Box>
                </Box>
              </Grid>
              <Grid size={6}>
                <Box sx={{ mb: 3 }}>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Languages
                  </Typography>
                  <Box sx={{ mt: 1 }}>
                    {data?.language && data?.language.length > 0 ? (
                      data.language.map((item, i) => (
                        <Chip
                          key={i}
                          label={item}
                          size='small'
                          variant='outlined'
                          sx={{ mr: 1, mb: 1, borderRadius: '16px' }}
                        />
                      ))
                    ) : (
                      <Typography variant='body2'>-</Typography>
                    )}
                  </Box>
                </Box>
              </Grid>
              <Grid size={6}>
                <Box sx={{ mb: 3 }}>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Identity Verification
                  </Typography>
                  <Typography variant='body1'>{data?.identityProofType || '-'}</Typography>
                </Box>
              </Grid>
              <Grid size={12}>
                <Box>
                  <Typography variant='body2' fontWeight={'medium'} color='text.secondary'>
                    Proof Document
                  </Typography>
                  <Box sx={{ overflow: 'hidden', borderRadius: '8px', display : "flex" , gap : 2 }}>
                    {data?.identityProof.length > 0
                      ? data?.identityProof.map((item, i) => {
                          return (
                            <a href={getFullImageUrl(item)} key={i}>
                            <CustomAvatar
                              alt={data?.name || data?.userId?.fullName || 'User'}
                              src={getFullImageUrl(item)}
                              skin='light'
                              color='primary'
                              variant='rounded'
                              size={60}
                            >
                              {(data?.name || data?.userId?.fullName || 'U').charAt(0)}
                            </CustomAvatar>
                             </a>
                          )
                        })
                      : ''}
                  </Box>
                </Box>
              </Grid>
            </Grid>
          </Box>
        </Box>
      </DialogContent>
      {/* </Paper> */}
    </Dialog>
  )
}

export default ReqViewDialog
