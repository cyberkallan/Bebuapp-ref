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

import { createTalkTopic, updateTalkTopic } from '@/redux-store/slices/talkTopics'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const TalkTopicDialog = ({ open, onClose, mode = 'create', talkTopic = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    name: ''
  })

  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && talkTopic) {
      setFormData({
        name: talkTopic.name || ''
      })
    } else {
      setFormData({
        name: ''
      })
    }
  }, [mode, talkTopic])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'name' && value.trim() !== '') {
        delete updatedErrors.name
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.name || formData.name.trim() === '') {
      newErrors.name = 'Topic name is required'
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
          updateTalkTopic({
            talkTopicId: talkTopic._id,
            name: formData.name
          })
        ).unwrap()
      } else {
        await dispatch(
          createTalkTopic({
            name: formData.name
          })
        ).unwrap()
      }

      setFormData({ name: '' })
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ name: '' })
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
      aria-labelledby='talktopic-dialog-title'
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
      <DialogTitle id='talktopic-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Talk Topic' : 'Create Talk Topic'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Topic Name'
          fullWidth
          value={formData.name}
          error={!!errors.name}
          helperText={errors.name || ''}
          onChange={e => handleChange('name', e.target.value)}
          placeholder='Family Issues'
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

export default TalkTopicDialog
