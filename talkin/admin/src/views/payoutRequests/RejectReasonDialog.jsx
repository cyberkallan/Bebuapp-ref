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

const RejectReasonDialog = ({ open, onClose, onSubmit, loading }) => {
  const [reason, setReason] = useState('')
  const [error, setError] = useState(null)

  const handleSubmit = () => {
    if (!reason.trim()) {
      setError('Please provide a reason for rejection')

      return
    }

    onSubmit(reason)
  }

  const handleClose = () => {
    setReason('')
    setError(null)
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
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
          Reject Payout Request
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>
      <DialogContent className='pb-4 pt-6'>
        <TextField
          label='Reason for Rejection'
          multiline
          rows={4}
          fullWidth
          value={reason}
          onChange={e => {
            setReason(e.target.value)
            setError(null)
          }}
          error={!!error}
          helperText={error}
          placeholder='Please provide a reason for rejecting this payout request'
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button onClick={handleSubmit} variant='contained' color='error' disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : 'Reject Request'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default RejectReasonDialog
