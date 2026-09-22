'use client'

import React, { forwardRef, useEffect, useRef, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Slide,
  Button,
  TextField,
  Typography,
  CircularProgress,
  Box,
  Autocomplete,
  Chip,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem
} from '@mui/material'
import Avatar from '@mui/material/Avatar'
import ListItemText from '@mui/material/ListItemText'
import ListItemAvatar from '@mui/material/ListItemAvatar'

import DialogCloseButton from '@/components/dialogs/DialogCloseButton'
import StyledFileInput from '@/@layouts/styles/inputs/StyledFileInput'
import { fetchUserList, createVideo, updateVideo } from '@/redux-store/slices/videos'
import { fetchHashtags } from '@/redux-store/slices/hashtags'
import { getFullImageUrl } from '@/utils/commonfunctions'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const VideoDialog = ({ open, onClose, editData = null }) => {
  const dispatch = useDispatch()
  const { users, loading, selectedVideoType } = useSelector(state => state.videos)
  const { hashtags } = useSelector(state => state.hashtagsReducer)

  // Store selected users separately to preserve them during search
  const [selectedUsers, setSelectedUsers] = useState([])

  // Simplified search state
  const [userSearchValue, setUserSearchValue] = useState('')
  const searchTimerRef = useRef(null)

  const [formData, setFormData] = useState({
    userId: null,
    mentionedUserIds: [],
    hashTagId: [],
    caption: '',
    videoTime: ''
  })

  const [uploaderDetails, setUploaderDetails] = useState(null)
  const [video, setVideo] = useState(null)
  const [videoThumbnail, setVideoThumbnail] = useState(null)
  const [videoPreviewUrl, setVideoPreviewUrl] = useState('')
  const [thumbnailPreviewUrl, setThumbnailPreviewUrl] = useState('')
  const [errors, setErrors] = useState({})
  const [isAutoThumbnailGenerated, setIsAutoThumbnailGenerated] = useState(false)
  const videoRef = useRef(null)

  // Handle search with proper debouncing
  const handleUserSearch = searchText => {
    // Clear any existing timer first to prevent multiple calls
    if (searchTimerRef.current) {
      clearTimeout(searchTimerRef.current)
    }

    // Update the input value immediately for responsive UI
    setUserSearchValue(searchText)

    // Only make API call after a delay
    searchTimerRef.current = setTimeout(() => {
      const userType = selectedVideoType === 'fakeVideo' ? 'fake' : 'real'
      const searchParam = searchText && searchText.length >= 2 ? searchText : 'All'

      dispatch(
        fetchUserList({
          type: userType,
          search: searchParam
        })
      )
    }, 500)
  }

  // Initial data load
  useEffect(() => {
    if (open) {
      const userType = selectedVideoType === 'fakeVideo' ? 'fake' : 'real'

      dispatch(fetchUserList({ type: userType, search: 'All' }))

      dispatch(fetchHashtags())
    }

    // Cleanup timer on unmount
    return () => {
      if (searchTimerRef.current) {
        clearTimeout(searchTimerRef.current)
      }
    }
  }, [dispatch, open, selectedVideoType])

  // Handle edit mode
  useEffect(() => {
    if (editData && users.length > 0 && hashtags.length > 0) {
      // Handle both normalized and non-normalized data structures
      const userId = typeof editData.userId === 'object' ? editData.userId._id : editData.userId

      // Handle hashtags from both structures
      let hashTagIds = []

      if (editData.hashTags && Array.isArray(editData.hashTags)) {
        hashTagIds = editData.hashTags.map(tag => tag._id)
      } else if (editData.hashTagId && Array.isArray(editData.hashTagId)) {
        hashTagIds = editData.hashTagId
      }

      // Handle mentioned users from both structures
      let mentionedIds = []

      if (editData.mentionedUsers && Array.isArray(editData.mentionedUsers)) {
        mentionedIds = editData.mentionedUsers.map(user => (typeof user === 'object' ? user._id : user))
      } else if (editData.mentionedUserIds && Array.isArray(editData.mentionedUserIds)) {
        mentionedIds = editData.mentionedUserIds
      }

      setFormData(prev => ({
        ...prev,
        userId: userId || null,
        mentionedUserIds: mentionedIds,
        hashTagId: hashTagIds,
        caption: editData.caption || '',
        videoTime: editData.videoTime || ''
      }))

      // Store uploader details
      if (editData.userId) {
        // Find the user in users array if available
        const userObj = users.find(user => user._id === editData.userId)

        setUploaderDetails(
          userObj || {
            _id: editData.userId,
            name: editData.name || 'User',
            image: editData.userImage
          }
        )
      }

      if (editData.videoUrl) {
        setVideoPreviewUrl(getFullImageUrl(editData.videoUrl))
      }

      if (editData.videoImage) {
        setThumbnailPreviewUrl(getFullImageUrl(editData.videoImage))
      }
    }
  }, [editData, users, hashtags])

  // Set selectedUsers when the component loads or when we get mentioned users from editData
  useEffect(() => {
    // If we have mentionedUserIds but no selectedUsers yet
    if (formData.mentionedUserIds.length > 0 && selectedUsers.length === 0 && users.length > 0) {
      // Find all corresponding user objects for the mentionedUserIds
      const mentionedUserObjects = formData.mentionedUserIds
        .map(id => users.find(user => user._id === id))
        .filter(Boolean) // Remove any undefined entries

      setSelectedUsers(mentionedUserObjects)
    }
  }, [formData.mentionedUserIds, selectedUsers.length, users])

  // Handle dialog close
  const handleClose = () => {
    resetForm()
    onClose()
    setUploaderDetails(null)
  }

  // Reset form when dialog closes
  useEffect(() => {
    if (!open) {
      resetForm()
      setUploaderDetails(null)
    }
  }, [open])

  // Reset form function
  const resetForm = () => {
    setFormData({
      userId: null,
      mentionedUserIds: [],
      hashTagId: [],
      caption: '',
      videoTime: ''
    })
    setVideo(null)
    setVideoThumbnail(null)
    setVideoPreviewUrl('')
    setThumbnailPreviewUrl('')
    setErrors({})
    setIsAutoThumbnailGenerated(false)
    setUserSearchValue('')
    setSelectedUsers([])
  }

  // Generate thumbnail from video
  const generateThumbnail = videoFile => {
    const video = document.createElement('video')
    const canvas = document.createElement('canvas')
    const context = canvas.getContext('2d')

    // Set up video event handlers
    video.onloadedmetadata = () => {
      canvas.width = video.videoWidth
      canvas.height = video.videoHeight

      // We'll take a thumbnail at 1 second mark or at video midpoint if shorter
      const timeToCapture = Math.min(1, video.duration / 2)

      video.currentTime = timeToCapture
    }

    video.onseeked = () => {
      // Draw the video frame to the canvas
      context.drawImage(video, 0, 0, canvas.width, canvas.height)

      // Convert the canvas to a blob
      canvas.toBlob(
        blob => {
          if (blob) {
            const thumbnailFile = new File([blob], 'thumbnail.jpg', { type: 'image/jpeg' })

            setVideoThumbnail(thumbnailFile)
            setThumbnailPreviewUrl(URL.createObjectURL(thumbnailFile))
            setIsAutoThumbnailGenerated(true)
          } else {
            console.error('Failed to create thumbnail blob')
            setIsAutoThumbnailGenerated(false)
          }
        },
        'image/jpeg',
        0.95
      )
    }

    video.onerror = () => {
      console.error('Error loading video for thumbnail generation')
      setIsAutoThumbnailGenerated(false)
    }

    // Set video source and load
    video.src = URL.createObjectURL(videoFile)
  }

  // Handle video file selection
  const handleVideoChange = e => {
    const file = e.target.files[0]

    if (file) {
      setVideo(file)
      setVideoPreviewUrl(URL.createObjectURL(file))
      generateThumbnail(file)

      // Set video duration if we can
      const video = document.createElement('video')

      video.onloadedmetadata = () => {
        // Round to nearest integer seconds
        const durationInSeconds = Math.round(video.duration)

        setFormData(prev => ({
          ...prev,
          videoTime: durationInSeconds.toString()
        }))
      }

      video.src = URL.createObjectURL(file)
    }
  }

  // Handle manual thumbnail upload
  const handleThumbnailChange = e => {
    const file = e.target.files[0]

    if (file) {
      setVideoThumbnail(file)
      setThumbnailPreviewUrl(URL.createObjectURL(file))
      setIsAutoThumbnailGenerated(false)
    }
  }

  // Handle form input changes
  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setErrors(prev => ({ ...prev, [field]: null }))
  }

  // Validate the form
  const validate = () => {
    const newErrors = {}

    if (!formData.userId) newErrors.userId = 'Please select a user'
    if (!formData.caption.trim()) newErrors.caption = 'Caption is required'
    if (!video && !videoPreviewUrl) newErrors.video = 'Please upload a video'
    if (!videoThumbnail && !thumbnailPreviewUrl) newErrors.thumbnail = 'Thumbnail is required'
    if (!formData.videoTime) newErrors.video = 'Video duration could not be determined'

    setErrors(newErrors)

    return Object.keys(newErrors).length === 0
  }

  // Handle form submission
  const handleSubmit = async () => {
    if (!validate()) return

    const body = new FormData()

    // Append form data
    if (formData.userId) body.append('userId', formData.userId)

    // Handle mentioned users array
    if (formData.mentionedUserIds.length > 0) {
      formData.mentionedUserIds.forEach(userId => {
        body.append('mentionedUserIds', userId)
      })
    }

    // Handle hashtags array
    if (formData.hashTagId && formData.hashTagId.length > 0) {
      body.append('hashTagId', formData.hashTagId.join(','))
    }

    body.append('caption', formData.caption)
    body.append('videoTime', formData.videoTime)

    // Append files if new ones are selected
    if (video) body.append('videoUrl', video)
    if (videoThumbnail) body.append('videoImage', videoThumbnail)

    try {
      setLoading(true)

      // If we have editData, this is an update
      if (editData) {
        await dispatch(
          updateVideo({
            formData: body,
            userId: formData.userId,
            videoId: editData._id
          })
        ).unwrap()
      } else {
        await dispatch(
          createVideo({
            formData: body,
            userId: formData.userId
          })
        ).unwrap()
      }

      onClose()
      resetForm()
    } catch (error) {
      console.error('Error submitting form:', error)
      setErrors(prev => ({ ...prev, submit: error.message || 'Failed to submit video' }))
    } finally {
      setLoading(false)
    }
  }

  // Combine server-side search results with already selected users
  const getAutocompleteOptions = () => {
    // Create a set of IDs from the server results
    const serverUserIds = new Set(users.map(user => user._id))

    // Filter selected users to only include those not in the current server results
    const selectedUsersNotInResults = selectedUsers.filter(user => !serverUserIds.has(user._id))

    // Combine server results with the selected users that aren't in the results
    return [...users, ...selectedUsersNotInResults]
  }

  // Handle user selection in Autocomplete
  const handleUserSelectionChange = (_, newValue) => {
    // Update the selectedUsers state
    setSelectedUsers(newValue)

    // Update the formData with just the IDs

    const newMentionedUserIds = newValue.map(user => user._id)

    setFormData(prev => ({ ...prev, mentionedUserIds: newMentionedUserIds }))
  }

  return (
    <Dialog
      open={open}
      onClose={handleClose}
      keepMounted
      TransitionComponent={Transition}
      aria-labelledby='video-dialog'
      fullWidth
      maxWidth='md'
      PaperProps={{
        sx: {
          overflow: 'visible',
          maxWidth: '800px'
        }
      }}
    >
      <DialogTitle>
        <Typography variant='h5' component='div'>
          {editData ? 'Edit Video' : 'Upload New Video'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <i className='tabler-x' />
        </DialogCloseButton>
      </DialogTitle>

      <DialogContent className='flex flex-col gap-4 py-4'>
        {/* User Upload Selection */}
        {editData && uploaderDetails && (
          <Box display='flex' alignItems='center' p={2} sx={{ border: '1px solid #e0e0e0', borderRadius: 1 }}>
            <Avatar
              src={getFullImageUrl(uploaderDetails.image)}
              alt={uploaderDetails.name}
              sx={{ width: 40, height: 40, mr: 2 }}
            />
            <Typography variant='body1' fontWeight='medium'>
              {uploaderDetails.name}
            </Typography>
          </Box>
        )}

        {!editData && (
          <Grid item xs={12}>
            <FormControl fullWidth variant='outlined'>
              <InputLabel>Select User</InputLabel>
              <Select
                name='userId'
                value={formData.userId ?? ''}
                onChange={e => {
                  handleChange('userId', e.target.value)

                  // Reset mentioned users if the uploader changes to avoid having them in both lists
                  setFormData(prev => ({
                    ...prev,
                    mentionedUserIds: prev.mentionedUserIds.filter(id => id !== e.target.value)
                  }))
                }}
                label='Select User'
                disabled={loading}
                error={!!errors.userId}
                renderValue={selected => {
                  const selectedUser = users.find(user => user._id === selected) || {}

                  return (
                    <Box display='flex' alignItems='center'>
                      <Avatar
                        src={getFullImageUrl(selectedUser.image)}
                        alt={selectedUser.name}
                        sx={{ width: 24, height: 24, mr: 1 }}
                      />
                      <Typography>{selectedUser.name}</Typography>
                    </Box>
                  )
                }}
              >
                {users.map(user => (
                  <MenuItem key={user._id} value={user._id}>
                    <ListItemAvatar>
                      <Avatar src={getFullImageUrl(user.image)} alt={user.name} sx={{ width: 30, height: 30 }} />
                    </ListItemAvatar>
                    <ListItemText primary={user.name} />
                  </MenuItem>
                ))}
              </Select>
              {errors.userId && (
                <Typography color='error' variant='caption'>
                  {errors.userId}
                </Typography>
              )}
            </FormControl>
          </Grid>
        )}

        {/* Mentioned Users (Multiple Selection) */}
        <Autocomplete
          multiple
          options={getAutocompleteOptions()}
          getOptionLabel={option => option.name || ''}
          value={selectedUsers}
          onChange={handleUserSelectionChange}
          onInputChange={(_, newValue, reason) => {
            // Only trigger search when user is typing, not when selecting
            if (reason === 'input') {
              handleUserSearch(newValue)
            }
          }}
          inputValue={userSearchValue}
          renderTags={(value, getTagProps) =>
            value.map((option, index) => {
              const tagProps = getTagProps({ index })
              const { key, ...otherProps } = tagProps

              return (
                <Chip
                  key={option._id}
                  label={option.name}
                  avatar={<Avatar src={getFullImageUrl(option.image)} />}
                  {...otherProps}
                />
              )
            })
          }
          renderOption={(props, option) => (
            <li {...props} key={option._id}>
              <Box display='flex' alignItems='center'>
                <Avatar src={getFullImageUrl(option.image)} alt={option.name} sx={{ width: 24, height: 24, mr: 1 }} />
                <div>
                  <Typography>{option.name}</Typography>
                  {option.userName && (
                    <Typography variant='caption' color='text.secondary'>
                      @{option.userName}
                    </Typography>
                  )}
                </div>
              </Box>
            </li>
          )}
          renderInput={params => (
            <TextField
              {...params}
              label='Mentioned Users'
              fullWidth
              InputProps={{
                ...params.InputProps,
                endAdornment: (
                  <>
                    {loading && <CircularProgress size={20} color='inherit' />}
                    {params.InputProps.endAdornment}
                  </>
                )
              }}
            />
          )}
          isOptionEqualToValue={(option, value) => option._id === value._id}
          loading={loading}
          freeSolo
        />

        {/* Hashtags (Multiple Selection) */}
        <Autocomplete
          multiple
          options={hashtags}
          getOptionLabel={option => option.hashTag || ''}
          value={hashtags.filter(tag => formData.hashTagId.includes(tag._id)) || []}
          onChange={(_, newValue) => {
            const newHashTagIds = newValue.map(tag => tag._id)

            handleChange('hashTagId', newHashTagIds)
          }}
          renderTags={(value, getTagProps) =>
            value.map((option, index) => {
              const tagProps = getTagProps({ index })
              const { key, ...otherProps } = tagProps

              return <Chip key={option._id} label={option.hashTag} {...otherProps} />
            })
          }
          renderInput={params => <TextField {...params} label='Hashtags' fullWidth />}
          isOptionEqualToValue={(option, value) => option._id === value._id}
        />

        {/* Caption */}
        <TextField
          label='Caption'
          multiline
          rows={3}
          fullWidth
          value={formData.caption}
          onChange={e => handleChange('caption', e.target.value)}
          error={!!errors.caption}
          helperText={errors.caption}
        />

        {/* Media Upload Section */}
        <Box className='mb-4'>
          <Grid container spacing={2}>
            {/* Video Upload */}
            <Grid item xs={12} md={6}>
              <Typography variant='subtitle1' className='mb-2'>
                Video Upload
              </Typography>
              <StyledFileInput accept='video/*' label='Upload Video' onChange={handleVideoChange} />
              {(video || videoPreviewUrl) && (
                <Box
                  className='mt-2 border rounded p-2'
                  sx={{
                    height: '200px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    backgroundColor: '#f5f5f5'
                  }}
                >
                  <video
                    ref={videoRef}
                    src={videoPreviewUrl}
                    controls
                    style={{ maxWidth: '100%', maxHeight: '200px' }}
                  />
                </Box>
              )}
              {errors.video && (
                <Typography color='error' variant='caption'>
                  {errors.video}
                </Typography>
              )}
            </Grid>

            {/* Thumbnail Section */}
            <Grid item xs={12} md={6}>
              <Typography variant='subtitle1' className='mb-2'>
                Video Thumbnail
                {isAutoThumbnailGenerated && (
                  <Chip label='Auto-generated' color='success' size='small' sx={{ ml: 1 }} />
                )}
              </Typography>
              <StyledFileInput accept='image/*' label='Upload Manual Thumbnail' onChange={handleThumbnailChange} />
              {thumbnailPreviewUrl && (
                <Box
                  className='mt-2 border rounded p-2'
                  sx={{
                    height: '200px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    backgroundColor: '#f5f5f5'
                  }}
                >
                  <img
                    src={thumbnailPreviewUrl}
                    alt='Video Thumbnail'
                    style={{ maxWidth: '100%', maxHeight: '200px', objectFit: 'contain' }}
                  />
                </Box>
              )}
              {errors.thumbnail && (
                <Typography color='error' variant='caption'>
                  {errors.thumbnail}
                </Typography>
              )}
            </Grid>
          </Grid>
        </Box>

        {errors.submit && (
          <Typography color='error' variant='body2'>
            {errors.submit}
          </Typography>
        )}
      </DialogContent>

      <DialogActions className='p-4'>
        <Button onClick={handleClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button variant='contained' onClick={handleSubmit} disabled={loading}>
          {loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : editData ? 'Update' : 'Upload'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default VideoDialog
