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
import SVGAPlayer from '@/components/SVGAPlayer'
import { getFullImageUrl } from '@/utils/commonfunctions'
import { createFrame, updateFrame } from '@/redux-store/slices/frames'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const validityTypes = [
  { label: 'Days', value: 1 },
  { label: 'Months', value: 2 },
  { label: 'Years', value: 3 }
]

const frameTypes = [
  { label: 'Image', value: 1 },
  { label: 'GIF', value: 2 },
  { label: 'SVGA', value: 3 }
]

const CreateEditFrameDialog = ({ open, onClose, mode = 'create', frame = null }) => {
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
    if (mode === 'edit' && frame) {
      setFormData({
        name: frame.name || '',
        coin: frame.coin || '',
        validity: frame.validity || '',
        validityType: frame.validityType || 1,
        type: frame.type || 1
      })
      setFile(null)
      setSvgaThumbnail(null)
      setExistingImageUrl(getFullImageUrl(frame.image))
    }
  }, [mode, frame])

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => ({ ...prev, [field]: null }))

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
        const SVGALib = await import('svgaplayerweb')
        const fileURL = URL.createObjectURL(selectedFile)
        const canvas = document.createElement('canvas')

        canvas.width = 400
        canvas.height = 200
        document.body.appendChild(canvas)
        canvas.style.position = 'absolute'
        canvas.style.left = '-1000px'
        canvas.style.backgroundColor = '#f0f0f0'

        const parser = new SVGALib.Parser()
        const player = new SVGALib.Player(canvas)

        const videoItem = await new Promise((resolve, reject) => {
          parser.load(
            fileURL,
            item => (item ? resolve(item) : reject(new Error('Failed to parse SVGA'))),
            err => reject(err || new Error('Unknown SVGA error'))
          )
        })

        await player.setVideoItem(videoItem)

        let frameCount = 0
        const maxFrames = Math.min(videoItem.frames || 5, 5)

        const renderFrame = () => {
          player.stepToFrame(frameCount % maxFrames)
          frameCount++

          if (frameCount < 3) {
            setTimeout(renderFrame, 100)
          } else {
            try {
              canvas.toBlob(blob => {
                if (blob) {
                  const thumbnailFile = new File([blob], 'thumbnail.png', { type: 'image/png' })

                  setSvgaThumbnail(thumbnailFile)
                  document.body.removeChild(canvas)
                }
              }, 'image/png', 0.95)
            } catch (err) {
              console.error('Thumbnail error:', err)
              document.body.removeChild(canvas)
            }
          }
        }

        renderFrame()
      } catch (err) {
        console.error('SVGA processing failed:', err)
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
        body.append('image', file)

        if (svgaThumbnail) {
          body.append('svgaImage', svgaThumbnail)
        }
      } else {
        body.append('image', file)
      }
    }

    try {
      setLoading(true)

      if (mode === 'edit') {
        // 🔧 Add editFrame dispatch here
        await dispatch(updateFrame({ body, query: frame._id })).unwrap()
      } else {
        // 🔧 Add createFrame dispatch here
        await dispatch(createFrame(body)).unwrap()
      }

      handleClose()
    } catch (error) {
      console.error(error)
      setErrors({ submit: 'Failed to save frame.' })
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
    onClose()
  }

  const fileAccept = formData.type === 1 ? '.jpg,.jpeg,.png,.webp' : formData.type === 2 ? '.gif' : '.svga'

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='create-frame-dialog'
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
          {mode === 'edit' ? 'Edit Frame' : 'Create Frame'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        <TextField
          label='Frame Name'
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
          label='Frame Type'
          select
          fullWidth
          value={formData.type}
          onChange={e => handleChange('type', parseInt(e.target.value))}
        >
          {frameTypes.map(opt => (
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

export default CreateEditFrameDialog
