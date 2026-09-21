'use client'

import { useState, useEffect } from 'react'

import { useForm, Controller } from 'react-hook-form'
import { yupResolver } from '@hookform/resolvers/yup'
import * as yup from 'yup'

// MUI Imports
import Dialog from '@mui/material/Dialog'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import TextField from '@mui/material/TextField'
import Box from '@mui/material/Box'

// Define validation schema
const schema = yup.object().shape({
  title: yup.string().required('Title is required')
})

const ReportReasonDialog = ({ open, setOpen, reportReason, onSubmit, loading, error }) => {
  const isEditMode = Boolean(reportReason?._id)

  // Initialize form with react-hook-form
  const {
    control,
    handleSubmit,
    reset,
    formState: { errors }
  } = useForm({
    defaultValues: {
      title: ''
    },
    resolver: yupResolver(schema)
  })

  // Update form when reportReason changes
  useEffect(() => {
    if (reportReason) {
      reset({ title: reportReason.title })
    } else {
      reset({ title: '' })
    }
  }, [reportReason, reset])

  // Handle form submission
  const handleFormSubmit = data => {
    if (isEditMode) {
      onSubmit({ reportReasonId: reportReason._id, ...data })
    } else {
      onSubmit(data)
    }
  }

  // Handle dialog close
  const handleClose = () => {
    if (!loading) {
      setOpen(false)
      reset({ title: '' })
    }
  }

  return (
    <Dialog fullWidth maxWidth='sm' open={open} onClose={handleClose} closeAfterTransition={false}>
      <DialogContent className='sm:pbs-12 sm:pbe-4 sm:pli-12'>
        <Typography variant='h5' className='mbe-4 text-center'>
          {isEditMode ? 'Edit Report Reason' : 'Add New Report Reason'}
        </Typography>

        <form onSubmit={handleSubmit(handleFormSubmit)}>
          <Box className='mbe-6'>
            <Controller
              name='title'
              control={control}
              render={({ field }) => (
                <TextField
                  {...field}
                  fullWidth
                  label='Reason Title'
                  placeholder='Enter report reason title'
                  error={Boolean(errors.title)}
                  helperText={errors.title?.message}
                  disabled={loading}
                />
              )}
            />
          </Box>
          {error && (
            <Box className='mbe-4'>
              <Typography color='error' variant='body2' align='center'>
                {error}
              </Typography>
            </Box>
          )}
        </form>
      </DialogContent>
      <DialogActions className='justify-between sm:pbe-12 sm:pli-12 flex flex-wrap gap-2'>
        <Button variant='tonal' color='secondary' onClick={handleClose} disabled={loading}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit(handleFormSubmit)} disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : isEditMode ? 'Update' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default ReportReasonDialog
