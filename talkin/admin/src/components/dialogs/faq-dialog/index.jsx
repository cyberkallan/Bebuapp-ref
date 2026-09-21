'use client'

import { forwardRef, useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Slide from '@mui/material/Slide'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

import { toast } from 'react-toastify'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createFaq, updateFaq } from '@/redux-store/slices/faq'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const FaqDialog = ({ open, onClose, editData = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    category: 'User',
    question: '',
    answer: ''
  })

  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (editData) {
      setFormData({
        // category: editData.category || 'User',
        question: editData.question || '',
        answer: editData.answer || ''
      })
    } else {
      setFormData({
        // category: 'User',
        question: '',
        answer: ''
      })
    }
  }, [editData, open])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    if (value.trim() !== '') {
      setErrors(prev => {
        const updatedErrors = { ...prev }

        delete updatedErrors[field]
        
        return updatedErrors
      })
    }
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.question || formData.question.trim() === '') {
      newErrors.question = 'Question is required'
    }

    if (!formData.answer || formData.answer.trim() === '') {
      newErrors.answer = 'Answer is required'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }




  const handleSubmit = async () => {
   
      
    if (!handleValidation()) return

    try {
      setLoading(true)

      if (editData) {
        await dispatch(
          updateFaq({
            faqId: editData._id,
            category: formData.category,
            question: formData.question,
            answer: formData.answer
          })
        ).unwrap()
      } else {
        await dispatch(
          createFaq({
            category: formData.category,
            question: formData.question,
            answer: formData.answer
          })
        ).unwrap()
      }

      handleClose()
    } catch (error) {
      console.error('Error submitting form:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setFormData({
      // category: 'User',
      question: '',
      answer: ''
    })
    setErrors({})
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='faq-dialog-title'
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
      <DialogTitle id='faq-dialog-title'>
        <Typography variant='h5' component='span'>
          {editData ? 'Edit FAQ' : 'Create FAQ'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        

        <TextField
          label='Question'
          fullWidth
          value={formData.question}
          error={!!errors.question}
          helperText={errors.question || ''}
          onChange={e => handleChange('question', e.target.value)}
          placeholder='Enter the question'
          multiline
          rows={2}
        />

        <TextField
          label='Answer'
          fullWidth
          value={formData.answer}
          error={!!errors.answer}
          helperText={errors.answer || ''}
          onChange={e => handleChange('answer', e.target.value)}
          placeholder='Enter the answer'
          multiline
          rows={4}
        />
      </DialogContent>

      <DialogActions className='p-6 pt-0'>
        <Button variant='outlined' onClick={handleClose} disabled={loading}>
          Cancel
        </Button>
        <Button
          variant='contained'
          onClick={handleSubmit}
          disabled={loading}
          startIcon={loading && <CircularProgress size={20} />}
        >
          {editData ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default FaqDialog
