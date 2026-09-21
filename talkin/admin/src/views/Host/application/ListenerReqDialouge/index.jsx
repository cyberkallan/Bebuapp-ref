'use client'

import { forwardRef, useEffect, useState } from 'react'

import {
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Slide,
  TextField,
  Typography
} from '@mui/material'

import { useDispatch, useSelector } from 'react-redux'

import { toast } from 'react-toastify'

import DialogCloseButton from '@/components/dialogs/DialogCloseButton'

import { handleListenerRequest } from '@/redux-store/slices/listenerRequest'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const ReqReasonDialog = ({ open, onClose, data }) => {
  const dispatch = useDispatch()
  const [reason, setReason] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    setError('')
    
    return ()=>{
      setReason("")
      setError("")
    }
  }, [data, open])

  


  const handleSubmit = async () => {
    

    if (!reason.trim()) {

      setError('Reason is required')
      
      return
    }

    setLoading(true)
    
    try {
      await dispatch(
        handleListenerRequest({
          requestId: data._id,
          userId: data.userId._id,
          type: 3,
          reason
        })
      )
      onClose()
    } catch (err) {
      // error already handled by toast in thunk
    } finally {
      setLoading(false)
      setReason("")
      setError("")
    }
  }

  return (
    <Dialog
      open={open}
      keepMounted
      onClose={onClose}
      TransitionComponent={Transition}
      closeAfterTransition={false}
      fullWidth
      maxWidth='xs'
      PaperProps={{
        sx: {
          overflow: 'visible',
          width: '400px',
          maxWidth: '95vw'
        }
      }}
    >
      <DialogTitle>
        <Typography variant='h5' component='span'>
          Add Reasone
        </Typography>
        <DialogCloseButton onClick={onClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>
      <DialogContent>
        <TextField
          autoFocus
          margin='dense'
          label='Reason'
          fullWidth
          value={reason}
          onChange={e => {
            setReason(e.target.value)
            if (error) setError('')
          }}
          error={!!error}
          helperText={error}
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} variant='tonal' disabled={loading}>
          Cancel
        </Button>
        <Button onClick={handleSubmit} variant='contained' disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : 'Submit'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default ReqReasonDialog
