'use client'

import { forwardRef, useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import Box from '@mui/material/Box'
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

import CustomAvatar from '@/@core/components/mui/Avatar'
import CustomIconButton from '@/@core/components/mui/IconButton'
import { createPaymentOption, updatePaymentOption } from '@/redux-store/slices/paymentOptions'


import { baseURL } from '@/config'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const PaymentOptionDialog = ({ open, onClose, mode = 'create', paymentOption = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.paymentOptions)

  const [formData, setFormData] = useState({
    name: '',
    details: '',
    isActive: true,
    image: null
  })

  const [imagePreview, setImagePreview] = useState('')
  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    console.log('mode-->', mode)
    console.log('paymentOption-->', paymentOption)

    if (mode === 'edit' && paymentOption) {
      setFormData({
        name: paymentOption.name || '',
        details: Array.isArray(paymentOption.details) ? paymentOption.details.join(',') : '',
        isActive: paymentOption.isActive !== undefined ? paymentOption.isActive : true,
        image: null
      })

      if (paymentOption.image) {
        setImagePreview(`${baseURL}/${paymentOption.image}`)
      } else {
        setImagePreview('')
      }
    } else {
      setFormData({
        name: '',
        details: '',
        isActive: true,
        image: null
      })
      setImagePreview('')
    }
  }, [mode, paymentOption])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'name' && value.trim() !== '') {
        delete updatedErrors.name
      } else if (field === 'details' && value.trim() !== '') {
        delete updatedErrors.details
      }

      return updatedErrors
    })
  }

  const handleImageChange = e => {
    const file = e.target.files[0]

    console.log('file-->', file)

    if (file) {
      setFormData(prev => ({ ...prev, image: file }))
      setImagePreview(URL.createObjectURL(file))

      // Clear image error
      setErrors(prev => {
        const updatedErrors = { ...prev }

        delete updatedErrors.image
        
        return updatedErrors
      })
    }
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.name || formData.name.trim() === '') {
      newErrors.name = 'Name is required'
    }

    if (!formData.details || formData.details.trim() === '') {
      newErrors.details = 'Details are required'
    }

    // Only require image for create mode, not for edit mode
    if (!formData.image) {
      newErrors.image = 'Image is required'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }


  

  const handleSubmit = async () => {
     
    
    if (!handleValidation()) return

    try {
      setIsSubmitting(true)

      // Create FormData object for file upload
      const submitData = new FormData()

      submitData.append('name', formData.name)
      submitData.append('details', formData.details)

      if (formData.image) {
        submitData.append('image', formData.image)
      }

      if (mode === 'edit') {
        submitData.append('paymentOptionId', paymentOption._id)
        await dispatch(updatePaymentOption(submitData)).unwrap()
      } else {
        await dispatch(createPaymentOption(submitData)).unwrap()
      }

      resetForm()
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setIsSubmitting(false)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      details: '',
      isActive: true,
      image: null
    })
    setImagePreview('')
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
      aria-labelledby='payment-option-dialog-title'
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
      <DialogTitle id='payment-option-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Payment Option' : 'Create Payment Option'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Name'
          fullWidth
          value={formData.name}
          error={!!errors.name}
          helperText={errors.name || ''}
          onChange={e => handleChange('name', e.target.value)}
          placeholder='Bank Transfer'
        />
        <TextField
          label='Details'
          fullWidth
          multiline
          rows={3}
          value={formData.details}
          error={!!errors.details}
          helperText={
            errors.details || (
              <label className='text-error'>Separate each detail with a comma, e.g. &quot;Account Number,IFSC Code&quot;</label>
            )
          }
          onChange={e => handleChange('details', e.target.value)}
          placeholder='Account Number,IFSC Code'
        />

        <Box>
          <Typography variant='subtitle1' component='label' className='mb-2 block'>
            Image
          </Typography>
          {!imagePreview && (
            <>
              <input
                accept='image/png, image/jpeg, image/jpg'
                type='file'
                id='payment-option-image'
                onChange={handleImageChange}
                style={{ display: 'none' }}
              />
              <Box className='flex flex-col gap-4'>
                <label htmlFor='payment-option-image' className='w-full'>
                  <Button variant='outlined' color='primary' className='w-full' component='span'>
                    Choose Image
                  </Button>
                  <p className='text-xs text-error mt-0.5'>Accept only .png, .jpeg and .jpg</p>
                </label>
                {errors.image && (
                  <Typography variant='caption' className='text-error'>
                    {errors.image}
                  </Typography>
                )}
              </Box>
            </>
          )}
          {imagePreview && (
            <>
              <div className='mt-2 w-full'>
                <Box className='border p-2 rounded flex justify-between w-full items-center'>
                  <div className='flex items-center gap-4'>
                    <CustomAvatar size={60} variant='rounded' src={imagePreview} />
                    {formData?.image?.name && <p>{formData?.image.name || '-'}</p>}
                  </div>
                  <div
                    className=''
                    onClick={() => {
                      setFormData(prev => ({ ...prev, image: null }))
                      setImagePreview('')
                    }}
                  >
                    <CustomIconButton aria-label='capture screenshot' color='error'>
                      <i className='tabler-trash' />
                    </CustomIconButton>
                  </div>
                </Box>
              </div>
            </>
          )}
        </Box>
      </DialogContent>

      <DialogActions className='flex gap-4 p-6'>
        <Button variant='tonal' color='secondary' onClick={handleClose}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={isSubmitting || loading}>
          {isSubmitting || loading ? <CircularProgress size={24} /> : mode === 'edit' ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default PaymentOptionDialog
