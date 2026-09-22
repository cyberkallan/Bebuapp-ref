'use client'

import React from 'react'

// MUI Imports
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogContentText from '@mui/material/DialogContentText'
import DialogTitle from '@mui/material/DialogTitle'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import CircularProgress from '@mui/material/CircularProgress'

const DeleteConfirmDialog = ({ open, onClose, onConfirm, loading }) => {
  return (
    <Dialog
      open={open}
      onClose={loading ? undefined : onClose}
      aria-labelledby='delete-dialog-title'
      aria-describedby='delete-dialog-description'
    >
      <DialogTitle id='delete-dialog-title'>
        <Typography variant='h6'>Confirm Deletion</Typography>
      </DialogTitle>
      <DialogContent>
        <DialogContentText id='delete-dialog-description'>
          Are you sure you want to delete this listener? This action cannot be undone.
        </DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={loading}>
          Cancel
        </Button>
        <Button
          onClick={onConfirm}
          color='error'
          variant='contained'
          disabled={loading}
          startIcon={loading ? <CircularProgress size={20} /> : null}
        >
          {loading ? 'Deleting...' : 'Delete'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default DeleteConfirmDialog
