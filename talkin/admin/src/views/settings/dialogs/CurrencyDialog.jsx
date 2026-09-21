import React, { forwardRef, useEffect, useState } from 'react'

import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Slide,
  TextField,
  CircularProgress
} from '@mui/material'
import { useDispatch } from 'react-redux'

import { createCurrency, updateCurrency } from '@/redux-store/slices/currency'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const CurrencyDialog = ({ open, onClose, mode = 'create', currency = null }) => {
  const dispatch = useDispatch()
  const [loading, setLoading] = useState(false)

  const [formData, setFormData] = useState({
    name: '',
    symbol: '',
    countryCode: '',
    currencyCode: ''
  })

  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (mode === 'edit' && currency) {
      setFormData({
        name: currency.name || '',
        symbol: currency.symbol || '',
        countryCode: currency.countryCode || '',
        currencyCode: currency.currencyCode || ''
      })
    } else {
      setFormData({
        name: '',
        symbol: '',
        countryCode: '',
        currencyCode: ''
      })
    }

    setErrors({})
  }, [mode, currency, open])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => ({ ...prev, [field]: null }))
  }

  const validate = () => {
    const newErrors = {}

    if (!formData.name) newErrors.name = 'Currency name is required'
    if (!formData.symbol) newErrors.symbol = 'Currency symbol is required'
    if (!formData.countryCode) newErrors.countryCode = 'Country code is required'
    if (!formData.currencyCode) newErrors.currencyCode = 'Currency code is required'

    // Additional validation rules
    if (formData.countryCode && formData.countryCode.length !== 2) {
      newErrors.countryCode = 'Country code must be 2 characters'
    }

    if (formData.currencyCode && formData.currencyCode.length !== 3) {
      newErrors.currencyCode = 'Currency code must be 3 characters'
    }

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!validate()) return

    try {
      setLoading(true)

      if (mode === 'edit') {
        await dispatch(updateCurrency({ currencyId: currency._id, ...formData })).unwrap()
      } else {
        await dispatch(createCurrency(formData)).unwrap()
      }

      onClose()
    } catch (error) {
      console.error('Currency save failed:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onClose={onClose} TransitionComponent={Transition} fullWidth maxWidth='sm'>
      <DialogTitle>{mode === 'edit' ? 'Edit Currency' : 'Add New Currency'}</DialogTitle>
      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Currency Name'
          value={formData.name}
          onChange={e => handleChange('name', e.target.value)}
          error={!!errors.name}
          helperText={errors.name}
          fullWidth
          margin='normal'
        />
        <TextField
          label='Symbol'
          value={formData.symbol}
          onChange={e => handleChange('symbol', e.target.value)}
          error={!!errors.symbol}
          helperText={errors.symbol}
          fullWidth
          margin='normal'
        />
        <TextField
          label='Country Code (2 characters)'
          value={formData.countryCode}
          onChange={e => handleChange('countryCode', e.target.value.toUpperCase())}
          error={!!errors.countryCode}
          helperText={errors.countryCode}
          fullWidth
          margin='normal'
          inputProps={{ maxLength: 2 }}
        />
        <TextField
          label='Currency Code (3 characters)'
          value={formData.currencyCode}
          onChange={e => handleChange('currencyCode', e.target.value.toUpperCase())}
          error={!!errors.currencyCode}
          helperText={errors.currencyCode}
          fullWidth
          margin='normal'
          inputProps={{ maxLength: 3 }}
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button onClick={handleSubmit} variant='contained' disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : 'Submit'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default CurrencyDialog
