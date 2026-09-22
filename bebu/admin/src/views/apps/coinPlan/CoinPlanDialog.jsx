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

import { createCoinPlan, updateCoinPlan } from '@/redux-store/slices/coinPlans'


const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const CoinPlanDialog = ({ open, onClose, mode = 'create', plan = null }) => {
  const dispatch = useDispatch()
  const { settings } = useSelector(state => state.settings)

  const [formData, setFormData] = useState({
    coin: '',
    amount: '',
    productKey: ''
  })

  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && plan) {
      setFormData({
        coin: plan.coin ?? '',
        amount: plan.amount ?? '',
        productKey: plan.productKey ?? ''
      })
    }
  }, [mode, plan])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))

    // Clear field-specific error if valid
    setErrors(prev => {
      const updatedErrors = { ...prev }

      if (field === 'coin' && value && Number(value) > 0) {
        delete updatedErrors.coin
      }

      if (field === 'amount' && value && Number(value) > 0) {
        delete updatedErrors.amount
      }

      if (field === 'productKey' && value.trim() !== '') {
        delete updatedErrors.productKey
      }

      return updatedErrors
    })
  }

  const handleValidation = () => {
    const newErrors = {}

    if (!formData.coin || Number(formData.coin) <= 0) newErrors.coin = 'Enter a valid coin value'
    if (!formData.amount || Number(formData.amount) <= 0) newErrors.amount = 'Enter a valid amount'
    if (!formData.productKey) newErrors.productKey = 'Product key is required'

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  


  const handleSubmit = async () => {
    

    if (!handleValidation()) return

    try {
      setLoading(true)

      if (mode === 'edit') {
        await dispatch(updateCoinPlan({ id: plan._id, payload: formData })).unwrap()
      } else {
        await dispatch(createCoinPlan(formData)).unwrap()
      }

      setFormData({ coin: '', amount: '', productKey: '' })
      onClose()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors({ submit: 'An error occurred while submitting the form' })
    } finally {
      setLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({ coin: '', amount: '', productKey: '' })
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
      aria-labelledby='coin-plan-dialog-title'
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
      <DialogTitle id='coin-plan-dialog-title'>
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
          value={formData.coin}
          error={!!errors.coin}
          helperText={errors.coin}
          onChange={e => handleChange('coin', e.target.value)}
        />
        <TextField
          label={`Amount (${settings?.currency?.symbol})`}
          type='number'
          fullWidth
          value={formData.amount}
          error={!!errors.amount}
          helperText={errors.amount}
          onChange={e => handleChange('amount', e.target.value)}
        />
        <TextField
          label='Product Key'
          fullWidth
          value={formData.productKey}
          error={!!errors.productKey}
          helperText={errors.productKey}
          onChange={e => handleChange('productKey', e.target.value)}
        />
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

export default CoinPlanDialog
