'use client'

import React, { forwardRef, useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Slide from '@mui/material/Slide'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import TextField from '@mui/material/TextField'
import CircularProgress from '@mui/material/CircularProgress'

import { toast } from 'react-toastify'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createIdentityProof, updateIdentityProof } from '@/redux-store/slices/identityProofs'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const IdentityProofDialog = ({ open, onClose, mode = 'create', identityProof = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    title: ''
  })

  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && identityProof) {
      setFormData({
        title: identityProof.title || ''
      })
    } else {
      setFormData({
        title: ''
      })
    }
  }, [mode, identityProof])

  
  

  const handleChange = (field, value) => {
   
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'title' && value.trim() !== '') {
        delete updatedErrors.title
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.title || formData.title.trim() === '') {
      newErrors.title = 'Title is required'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    
    if (!handleValidation()) return

    try {
      setLoading(true)

      if (mode === 'edit') {
        await dispatch(
          updateIdentityProof({
            identityProofId: identityProof._id,
            title: formData.title
          })
        ).unwrap()
      } else {
        await dispatch(
          createIdentityProof({
            title: formData.title
          })
        ).unwrap()
      }

      setFormData({ title: '' })
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ title: '' })
    setErrors({})
  }

  const handleClose = () => {
    resetForm()
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='identity-proof-dialog-title'
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
      <DialogTitle id='identity-proof-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Identity Proof' : 'Add Identity Proof'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Title'
          fullWidth
          value={formData.title}
          error={!!errors.title}
          helperText={errors.title || ''}
          onChange={e => handleChange('title', e.target.value)}
          placeholder='Passport'
        />

        {errors.submit && (
          <Typography color='error' variant='body2'>
            {errors.submit}
          </Typography>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : 'Submit'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default IdentityProofDialog
