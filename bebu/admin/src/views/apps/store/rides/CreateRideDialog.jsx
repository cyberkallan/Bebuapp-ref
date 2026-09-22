'use client'

import React, { forwardRef, useEffect, useRef, useState } from 'react'

import { useDispatch } from 'react-redux'

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

import DialogCloseButton from '@components/dialogs/DialogCloseButton'
import { createRide, editRide } from '@/redux-store/slices/rides'
import StyledFileInput from '@/@layouts/styles/inputs/StyledFileInput'
import SVGAPlayer from '@/components/SVGAPlayer'
import { getFullImageUrl } from '@/utils/commonfunctions'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const validityTypes = [
  { label: 'Days', value: 1 },
  { label: 'Months', value: 2 },
  { label: 'Years', value: 3 }
]

const rideTypes = [
  { label: 'Image', value: 1 },
  { label: 'GIF', value: 2 },
  { label: 'SVGA', value: 3 }
]

const CreateRideDialog = ({ open, onClose, mode = 'create', ride = null }) => {
  const dispatch = useDispatch()

  const [formData, setFormData] = useState({
    name: '',
    coin: '',
    validity: '',
    validityType: 1,
    type: 1
  })

  const [file, setFile] = useState(null)
  const [existingImageUrl, setExistingImageUrl] = useState(null)
  const [svgaThumbnail, setSvgaThumbnail] = useState(null)
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (mode === 'edit' && ride) {
      setFormData({
        name: ride.name || '',
        coin: ride.coin || '',
        validity: ride.validity || '',
        validityType: ride.validityType || 1,
        type: ride.type || 1
      })
      setFile(null)
      setSvgaThumbnail(null)

      const fullImageUrl = getFullImageUrl(ride.image)

      setExistingImageUrl(fullImageUrl)
    }
  }, [mode, ride])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => ({ ...prev, [field]: null }))

    // 🔥 If ride type is changed, clear file and thumbnails to avoid format mismatch
    if (field === 'type') {
      setFile(null)
      setSvgaThumbnail(null)
      setExistingImageUrl(null)
    }
  }

  const handleFileChange = async e => {
    const selectedFile = e.target.files[0]

    setFile(selectedFile)
    setSvgaThumbnail(null)

    if (selectedFile && selectedFile.name.endsWith('.svga')) {
      try {
        // Import dynamically
        const SVGALib = await import('svgaplayerweb')

        // Create a blob URL for the file
        const fileURL = URL.createObjectURL(selectedFile)

        // Create a canvas element explicitly for thumbnail generation
        const canvas = document.createElement('canvas')

        canvas.width = 400 // Larger dimensions for better quality
        canvas.height = 200
        document.body.appendChild(canvas) // Temporarily add to DOM for better rendering

        // Initialize the parser and player
        const parser = new SVGALib.Parser()
        const player = new SVGALib.Player(canvas)

        // Ensure the canvas is visible and rendered correctly
        canvas.style.position = 'absolute'
        canvas.style.left = '-1000px' // Off-screen
        canvas.style.backgroundColor = '#f0f0f0' // Background to detect rendering issues

        // Load the SVGA file
        const videoItem = await new Promise((resolve, reject) => {
          parser.load(
            fileURL,
            videoItem => {
              if (videoItem) resolve(videoItem)
              else reject(new Error('Failed to parse SVGA file'))
            },
            error => {
              reject(error || new Error('Unknown parser error'))
            }
          )
        })

        // Set the video item to the player
        await player.setVideoItem(videoItem)

        // Set up a rendering cycle to ensure the content is fully rendered
        let frameCount = 0
        const maxFrames = Math.min(videoItem.frames || 5, 5) // Cap at 5 frames max

        const renderFrame = () => {
          player.stepToFrame(frameCount % maxFrames)

          frameCount++

          if (frameCount < 3) {
            // Render a few frames to ensure content appears
            setTimeout(renderFrame, 100)
          } else {
            // After rendering multiple frames, capture the thumbnail
            try {
              canvas.toBlob(
                blob => {
                  if (blob) {
                    const thumbnailFile = new File([blob], 'thumbnail.png', { type: 'image/png' })

                    setSvgaThumbnail(thumbnailFile)

                    // Clean up
                    document.body.removeChild(canvas)
                  } else {
                    console.error('Failed to create blob from canvas')
                  }
                },
                'image/png',
                0.95
              ) // Higher quality
            } catch (error) {
              console.error('Error creating thumbnail from canvas:', error)
              document.body.removeChild(canvas)
            }
          }
        }

        // Start the rendering cycle
        renderFrame()
      } catch (err) {
        console.error('Failed to generate SVGA thumbnail:', err)
      }
    }
  }

  const validate = () => {
    const newErrors = {}

    if (!formData.name.trim()) newErrors.name = 'Name is required'
    if (!formData.coin || Number(formData.coin) <= 0) newErrors.coin = 'Enter a valid coin amount'
    if (!formData.validity || Number(formData.validity) <= 0) newErrors.validity = 'Enter valid duration'
    if (!file && mode === 'create') newErrors.file = 'Please upload a file'

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
    body.append('type', formData.type)

    if (file) {
      if (formData.type === 3) {
        body.append('image', file) // SVGA

        if (svgaThumbnail) {
          body.append('svgaImage', svgaThumbnail) // SVGA thumbnail
        }
      } else {
        body.append('image', file) // Image or GIF
      }
    }

    try {
      setLoading(true)

      if (mode === 'edit') {
        const query = `${ride._id}`


        await dispatch(editRide({ body, query })).unwrap()
      } else {
        await dispatch(createRide(body)).unwrap()
      }

      onClose()
      setFormData({ name: '', coin: '', validity: '', validityType: 1, type: 1 })
      setFile(null)
    } catch (error) {
      console.error(error)
      setErrors({ submit: 'Failed to create ride' })
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setFormData({ name: '', coin: '', validity: '', validityType: 1, type: 1 })
    setFile(null)
    setSvgaThumbnail(null)
    setExistingImageUrl(null)
    setErrors({})
    ride = null
    onClose()
  }

  const fileAccept = formData.type === 1 ? '.jpg,.jpeg,.png,.webp' : formData.type === 2 ? '.gif' : '.svga'

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='create-ride-dialog'
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
        {mode === 'edit' ? 'Edit Ride' : 'Create Ride'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Ride Name'
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
        <TextField
          label='Ride Type'
          select
          fullWidth
          value={formData.type}
          onChange={e => handleChange('type', parseInt(e.target.value))}
        >
          {rideTypes.map(opt => (
            <MenuItem key={opt.value} value={opt.value}>
              {opt.label}
            </MenuItem>
          ))}
        </TextField>
        <div>
          <StyledFileInput
            accept={fileAccept}
            label={formData.type === 3 ? 'Upload SVGA File' : 'Upload Image/GIF'}
            onChange={handleFileChange}
          />
          {(file || existingImageUrl) && (
            <div className='mt-2 flex gap-4 items-start'>
              {formData.type === 3 ? (
                <>
                  <div className='rounded border border-gray-300 p-2 bg-gray-50'>
                    <SVGAPlayer url={file ? URL.createObjectURL(file) : existingImageUrl} width={200} height={100} />
                  </div>
                  {svgaThumbnail && (
                    <img
                      src={URL.createObjectURL(svgaThumbnail)}
                      alt='SVGA Thumbnail'
                      className='rounded border border-gray-300 max-w-[200px] max-h-[100px] object-contain'
                    />
                  )}
                </>
              ) : (
                <img
                  src={file ? URL.createObjectURL(file) : existingImageUrl}
                  alt='preview'
                  className='rounded border border-gray-300 max-w-[200px] max-h-[100px] object-contain'
                />
              )}
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

export default CreateRideDialog
