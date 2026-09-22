'use client'

import React, { forwardRef, useEffect, useState } from 'react'

import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Slide,
  Button,
  TextField,
  MenuItem,
  Typography,
  CircularProgress
} from '@mui/material'
import { useDispatch } from 'react-redux'

import DialogCloseButton from '@/components/dialogs/DialogCloseButton'
import StyledFileInput from '@/@layouts/styles/inputs/StyledFileInput'
import { createTheme, updateTheme } from '@/redux-store/slices/themes'
import { getFullImageUrl } from '@/utils/commonfunctions'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const validityTypes = [
  { label: 'Days', value: 1 },
  { label: 'Months', value: 2 },
  { label: 'Years', value: 3 }
]

const CreateEditThemeDialog = ({ open, onClose, mode = 'create', theme = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    name: '',
    coin: '',
    validity: '',
    validityType: 1
  })

  const [file, setFile] = useState(null)
  const [existingImageUrl, setExistingImageUrl] = useState(null)
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && theme) {
      setFormData({
        name: theme.name || '',
        coin: theme.coin || '',
        validity: theme.validity || '',
        validityType: theme.validityType || 1
      })
      setFile(null)
      const fullImageUrl = getFullImageUrl(theme.image)

      setExistingImageUrl(fullImageUrl)
    }
  }, [mode, theme])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => ({ ...prev, [field]: null }))
  }

  const handleFileChange = e => {
    const selectedFile = e.target.files[0]

    setFile(selectedFile)
  }

  const validate = () => {
    const newErrors = {}

    if (!formData.name.trim()) newErrors.name = 'Name is required'
    if (!formData.coin || Number(formData.coin) <= 0) newErrors.coin = 'Enter a valid coin amount'
    if (!formData.validity || Number(formData.validity) <= 0) newErrors.validity = 'Enter valid duration'
    if (!file && mode === 'create') newErrors.file = 'Please upload an image'

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async () => {
    if (!validate()) return

    const body = new FormData()

    body.append('name', formData.name)
    body.append('coin', formData.coin)
    body.append('validity', formData.validity)
    body.append('validityType', formData.validityType)

    if (file) {
      body.append('image', file)
    }

    try {
      setLoading(true)

      if (mode === 'edit') {
        await dispatch(updateTheme({ body, query: theme._id })).unwrap()
      } else {
        await dispatch(createTheme(body)).unwrap()
      }

      handleClose()
    } catch (error) {
      console.error(error)
      setErrors({ submit: 'Something went wrong while saving the theme.' })
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setFormData({ name: '', coin: '', validity: '', validityType: 1 })
    setFile(null)
    setExistingImageUrl(null)
    setErrors({})
    theme = null
    onClose()
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='create-theme-dialog'
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
        <Typography variant='h5' component='div'>
          {mode === 'edit' ? 'Edit Theme' : 'Create Theme'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Theme Name'
          fullWidth
          value={formData.name}
          error={!!errors.name}
          helperText={errors.name}
          onChange={e => handleChange('name', e.target.value)}
        />

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
          label='Validity'
          type='number'
          fullWidth
          value={formData.validity}
          error={!!errors.validity}
          helperText={errors.validity}
          onChange={e => handleChange('validity', e.target.value)}
        />

        <TextField
          label='Validity Type'
          select
          fullWidth
          value={formData.validityType}
          onChange={e => handleChange('validityType', e.target.value)}
        >
          {validityTypes.map(opt => (
            <MenuItem key={opt.value} value={opt.value}>
              {opt.label}
            </MenuItem>
          ))}
        </TextField>

        <div>
          <StyledFileInput
            accept='.jpg,.jpeg,.png,.gif,.webp'
            label='Upload Theme Image'
            onChange={handleFileChange}
          />
          {(file || existingImageUrl) && (
            <div className='mt-2 flex gap-4 items-start'>
              <img
                src={file ? URL.createObjectURL(file) : existingImageUrl}
                alt='preview'
                className='rounded border border-gray-300 max-w-[200px] max-h-[100px] object-contain'
              />
            </div>
          )}
          {errors.file && (
            <Typography color='error' variant='caption'>
              {errors.file}
            </Typography>
          )}
        </div>
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

export default CreateEditThemeDialog
