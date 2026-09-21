import React, { forwardRef, useState } from 'react'

import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Slide,
  Typography,
  CircularProgress
} from '@mui/material'

import DialogCloseButton from '@/components/dialogs/DialogCloseButton'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const ReasonDialog = ({ open, onClose, onSubmit, loading , reason }) => {
  return (
    <Dialog
      open={open}
      onClose={onClose}
      keepMounted
      TransitionComponent={Transition}
      fullWidth
      maxWidth='sm'
      PaperProps={{
        sx: {
          overflow: 'visible',
          width: '600px',
          maxWidth: '95vw'
        }
      }}
    >
      <DialogTitle>
        <Typography variant='h5' component='span'>
          Reject Reason
        </Typography>
        <DialogCloseButton onClick={onClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>
      <DialogContent className='pb-4'>
       {reason }
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} variant='tonal' color='primary'>
        Close
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default ReasonDialog
