import React, { useState, useRef, useEffect } from 'react'

import { Typography, Box, Button, Avatar, IconButton } from '@mui/material'
import { AddPhotoAlternate as AddPhotoIcon } from '@mui/icons-material'
import { useSelector, useDispatch } from 'react-redux'
import { toast } from 'react-toastify'

import { addProfilePhoto, removeProfilePhoto } from '@/redux-store/slices/settings'
import { getFullImageUrl } from '@/utils/commonfunctions'

const ProfileManagement = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)
  



  const fileInputRef = useRef()

  const [newImages, setNewImages] = useState([])

  // Cleanup blob URLs when component unmounts or newImages changes
  useEffect(() => {
    return () => {
      newImages.forEach(img => {
        if (img.preview) {
          URL.revokeObjectURL(img.preview)
        }
      })
    }
  }, [newImages])

  const handleImageSelect = e => {
    const files = Array.from(e.target.files)

    const selected = files.map(file => ({
      file,
      preview: URL.createObjectURL(file),
      id: Math.random().toString(36).substring(2, 9) // Add a unique ID for each image
    }))

    // Add new images to the array
    setNewImages(prev => [...selected, ...prev])
    e.target.value = null
  }

  const handleSaveChanges = async () => {
    

    const formData = new FormData()

    formData.append('settingId', settings._id)
    formData.append('action', 'add')
    newImages.forEach(img => {
      formData.append('profilePhotoList', img.file)
    })

    await dispatch(addProfilePhoto(formData))

    // Clean up blob URLs before clearing the array
    newImages.forEach(img => {
      if (img.preview) {
        URL.revokeObjectURL(img.preview)
      }
    })
    setNewImages([])
  }

  const handleRemoveExistingImage = async index => {
    const formData = new FormData()

    formData.append('settingId', settings._id)
    formData.append('action', 'remove')
    formData.append('index', index)

    await dispatch(removeProfilePhoto(formData))
  }

  const handleRemoveNewImage = index => {
    const removed = newImages[index]

    // Revoke the blob URL to free up memory
    if (removed.preview) {
      URL.revokeObjectURL(removed.preview)
    }

    setNewImages(prev => prev.filter((_, i) => i !== index))
  }

  return (
    <Box>
      <Box my={5} display='flex' justifyContent='space-between' alignItems='center'>
        <Typography variant='h5' gutterBottom>
          Profile Management
        </Typography>

        {newImages.length > 0 && (
          <Button variant='contained' color='primary' onClick={handleSaveChanges} disabled={loading}>
            Save Changes
          </Button>
        )}
      </Box>

      <Box sx={{ display: 'flex', gap: 3, flexWrap: 'wrap', alignItems: 'start', mt: 2 }}>
        {/* Add Image Button FIRST */}
        <Box sx={{ textAlign: 'center' }}>
          <IconButton
            color='primary'
            component='span'
            onClick={() => fileInputRef.current.click()}
            sx={{
              width: 200,
              height: 200,
              border: '2px dashed #ccc',
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto'
            }}
          >
            <AddPhotoIcon sx={{ fontSize: 32 }} />
            <input type='file' ref={fileInputRef} accept='image/*' multiple hidden onChange={handleImageSelect} />
          </IconButton>
        </Box>

        {/* New Selected Images (shown first) */}
        {newImages.map((img, index) => (
          <Box key={img.id || `new-${index}`} className='flex flex-col items-center justify-start'>
            <Avatar
              src={img.preview}
              alt='new profile'
              sx={{
                width: 200,
                height: 200,
                margin: '0 auto',
                bgcolor: 'grey.300'
              }}
            />
            <Button
              size='small'
              color='error'
              onClick={() => handleRemoveNewImage(index)}
              sx={{ mt: 1, fontSize: '0.75rem' }}
            >
              Remove
            </Button>
          </Box>
        ))}

        {/* Existing Images */}
        {settings?.profilePhotoList?.map((img, index) => (
          <Box key={`existing-${index}`} className='flex flex-col items-center justify-start'>
            <Avatar
              src={getFullImageUrl(img)}
              alt='profile'
              sx={{
                width: 200,
                height: 200,
                margin: '0 auto',
                bgcolor: 'grey.300'
              }}
            />
            <Button
              size='small'
              color='error'
              onClick={() => handleRemoveExistingImage(index)}
              sx={{ mt: 1, fontSize: '0.75rem' }}
            >
              Remove
            </Button>
          </Box>
        ))}
      </Box>
    </Box>
  )
}

export default ProfileManagement
