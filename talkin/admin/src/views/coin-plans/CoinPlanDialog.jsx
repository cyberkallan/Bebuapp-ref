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
import FormControlLabel from '@mui/material/FormControlLabel'
import Switch from '@mui/material/Switch'
import { toast } from 'react-toastify'

import DialogCloseButton from '@components/dialogs/DialogCloseButton'

import { createCoinPlan, updateCoinPlan } from '@/redux-store/slices/coinPlans'



const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const CoinPlanDialog = ({ open, onClose, mode = 'create', coinPlan = null }) => {
  const dispatch = useDispatch()
  const { loading } = useSelector(state => state.coinPlansReducer)

  const [formData, setFormData] = useState({
    coins: '',
    price: '',
    productId: '',
    isPopular: false,
    isActive: true
  })

  const [errors, setErrors] = useState({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && coinPlan) {
      setFormData({
        coins: coinPlan.coins || '',
        price: coinPlan.price || '',
        productId: coinPlan.productId || '',
        isPopular: coinPlan.isPopular || false,
        isActive: coinPlan.isActive !== undefined ? coinPlan.isActive : true
      })
    } else {
      setFormData({
        coins: '',
        price: '',
        productId: '',
        isPopular: false,
        isActive: true
      })
    }
  }, [mode, coinPlan])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'coins' && value > 0) {
        delete updatedErrors.coins
      } else if (field === 'price' && value > 0) {
        delete updatedErrors.price
      } else if (field === 'productId' && value.trim() !== '') {
        delete updatedErrors.productId
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.coins || formData.coins <= 0) {
      newErrors.coins = 'Coins must be a positive number'
    }

    if (!formData.price || formData.price <= 0) {
      newErrors.price = 'Price must be a positive number'
    }

    if (!formData.productId || formData.productId.trim() === '') {
      newErrors.productId = 'Product ID is required'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  


  const handleSubmit = async () => {
      
    
    if (!handleValidation()) return

    try {
      setIsSubmitting(true)

      if (mode === 'edit') {
        await dispatch(
          updateCoinPlan({
            coinPlanId: coinPlan._id,
            ...formData
          })
        ).unwrap()
      } else {
        await dispatch(createCoinPlan(formData)).unwrap()
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
      coins: '',
      price: '',
      productId: '',
      isPopular: false,
      isActive: true
    })
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
      aria-labelledby='coinplan-dialog-title'
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
      <DialogTitle id='coinplan-dialog-title'>
        <Typography variant='h5' component='span'>
          {mode === 'edit' ? 'Edit Coin Plan' : 'Create Coin Plan'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Coins'
          type='number'
          fullWidth
          value={formData.coins}
          error={!!errors.coins}
          helperText={errors.coins || ''}
          onChange={e => handleChange('coins', parseInt(e.target.value, 10) || '')}
          placeholder='1000'
          inputProps={{ min: 1 }}
        />

        <TextField
          label='Price'
          type='number'
          fullWidth
          value={formData.price}
          error={!!errors.price}
          helperText={errors.price || ''}
          onChange={e => handleChange('price', parseFloat(e.target.value) || '')}
          placeholder='9.99'
          inputProps={{ min: 0.01, step: 0.01 }}
        />

        <TextField
          label='Product ID'
          fullWidth
          value={formData.productId}
          error={!!errors.productId}
          helperText={errors.productId || ''}
          onChange={e => handleChange('productId', e.target.value)}
          placeholder='com.example.app.coinpack1000'
        />

        {/* <div className='flex flex-col gap-2'>
          <FormControlLabel
            control={
              <Switch checked={formData.isPopular} onChange={e => handleChange('isPopular', e.target.checked)} />
            }
            label='Popular'
          />

          <FormControlLabel
            control={<Switch checked={formData.isActive} onChange={e => handleChange('isActive', e.target.checked)} />}
            label='Active'
          />
        </div> */}
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

export default CoinPlanDialog
