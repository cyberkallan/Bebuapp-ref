'use client'

import { useState, useEffect, forwardRef, useCallback, useRef } from 'react'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Button from '@mui/material/Button'
import TextField from '@mui/material/TextField'
import FormControl from '@mui/material/FormControl'
import InputLabel from '@mui/material/InputLabel'
import Select from '@mui/material/Select'
import MenuItem from '@mui/material/MenuItem'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import IconButton from '@mui/material/IconButton'
import CircularProgress from '@mui/material/CircularProgress'
import Chip from '@mui/material/Chip'
import Autocomplete from '@mui/material/Autocomplete'
import Grid from '@mui/material/Grid'
import Slide from '@mui/material/Slide'
import Avatar from '@mui/material/Avatar'
import ListItemText from '@mui/material/ListItemText'
import ListItemAvatar from '@mui/material/ListItemAvatar'

// Icons
import CloseIcon from '@mui/icons-material/Close'
import AddPhotoAlternateIcon from '@mui/icons-material/AddPhotoAlternate'
import DeleteIcon from '@mui/icons-material/Delete'

// Component Imports
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'

// Actions
import { fetchUserList, createFakePost, updatePost } from '@/redux-store/slices/posts'
import { fetchHashtags } from '@/redux-store/slices/hashtags'
import { getFullImageUrl } from '@/utils/commonfunctions'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

const PostDialog = ({ open, onClose, editData }) => {
  const dispatch = useDispatch()
  const { users, loading, selectedPostType } = useSelector(state => state.posts)
  const { hashtags } = useSelector(state => state.hashtagsReducer)

  const isEditMode = Boolean(editData)

  // Simplified search state
  const [userSearchValue, setUserSearchValue] = useState('')
  const searchTimerRef = useRef(null)

  // Store selected users separately to preserve them during search
  const [selectedUsers, setSelectedUsers] = useState([])

  const [formData, setFormData] = useState({
    caption: '',
    userId: '',
    hashTags: [],
    images: [],
    mentionedUserIds: []
  })

  const [uploaderDetails, setUploaderDetails] = useState(null)
  const [imageFiles, setImageFiles] = useState([])
  const [imagePreviewUrls, setImagePreviewUrls] = useState([])
  const [uploadProgress, setUploadProgress] = useState(0)

  // Reset form state without dependencies on state variables
  const resetForm = () => {
    // Revoke any object URLs to prevent memory leaks
    if (imagePreviewUrls.length > 0) {
      imagePreviewUrls.forEach(url => {
        URL.revokeObjectURL(url)
      })
    }

    // Reset form state
    setFormData({
      caption: '',
      userId: '',
      hashTags: [],
      images: [],
      mentionedUserIds: []
    })

    setSelectedUsers([])
    setImageFiles([])
    setImagePreviewUrls([])
    setUploadProgress(0)
    setUserSearchValue('')
    setSelectedUsers([])
  }

  // Create a wrapped onClose handler that cleans up resources
  const handleClose = () => {
    if (!isEditMode) {
      resetForm()
    }

    onClose()
  }

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
      const userType = selectedPostType === 'fakePost' ? 'fake' : 'real'
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
      const userType = selectedPostType === 'fakePost' ? 'fake' : 'real'

      dispatch(fetchUserList({ type: userType, search: 'All' }))
      dispatch(fetchHashtags())
    }

    // Cleanup timer on unmount
    return () => {
      if (searchTimerRef.current) {
        clearTimeout(searchTimerRef.current)
      }
    }
  }, [dispatch, open, selectedPostType])

  // Set up form data when in edit mode
  useEffect(() => {
    if (isEditMode && editData) {
      // Extract mentioned users, handling both data structures
      let mentionedUsers = []

      if (editData.mentionedUsers && Array.isArray(editData.mentionedUsers)) {
        mentionedUsers = editData.mentionedUsers.map(user => (typeof user === 'object' ? user._id : user))
      } else if (editData.mentionedUserIds && Array.isArray(editData.mentionedUserIds)) {
        mentionedUsers = editData.mentionedUserIds
      }

      setFormData({
        caption: editData.caption || '',
        userId: editData.userId || '',
        hashTags: editData.hashTags || [],
        mentionedUserIds: mentionedUsers
      })

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

      // Prepare image previews for existing images
      if (editData.postImage && editData.postImage.length > 0) {
        const previews = editData.postImage.map(img => getFullImageUrl(img.url))

        setImagePreviewUrls(previews)
      } else {
        setImagePreviewUrls([])
      }
    } else if (!isEditMode && open) {
      // Only reset when opening in create mode
      resetForm()

      setUploaderDetails(null)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isEditMode, editData, open, users])

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

  const handleInputChange = e => {
    const { name, value } = e.target

    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleHashtagChange = (_, newValue) => {
    setFormData(prev => ({ ...prev, hashTags: newValue }))
  }

  const handleImageChange = e => {
    if (e.target.files) {
      const filesArray = Array.from(e.target.files)

      // Create preview URLs
      const newImagePreviewUrls = filesArray.map(file => URL.createObjectURL(file))

      setImageFiles(prev => [...prev, ...filesArray])
      setImagePreviewUrls(prev => [...prev, ...newImagePreviewUrls])
    }
  }

  const removeImage = index => {
    const newImageFiles = [...imageFiles]
    const newImagePreviewUrls = [...imagePreviewUrls]

    // Revoke the object URL to avoid memory leaks
    URL.revokeObjectURL(newImagePreviewUrls[index])

    newImageFiles.splice(index, 1)
    newImagePreviewUrls.splice(index, 1)

    setImageFiles(newImageFiles)
    setImagePreviewUrls(newImagePreviewUrls)
  }

  const handleSubmit = async () => {
    const formDataToSend = new FormData()

    if (formData.mentionedUserIds.length) {
      formData.mentionedUserIds.forEach(id => {
        formDataToSend.append('mentionedUserIds', id)
      })
    }

    formDataToSend.append('caption', formData.caption)

    // Add hashtags
    if (formData.hashTags && formData.hashTags.length > 0) {
      const hashTagIds = formData.hashTags.map(tag => tag._id).join(',')

      formDataToSend.append('hashTagId', hashTagIds)
    }

    // Add images
    imageFiles.forEach(file => {
      formDataToSend.append('postImage', file)
    })

    // Extract the user ID correctly whether it's an object or a string
    const getUserId = userId => {
      // If userId is an object with _id property, return that
      if (userId && typeof userId === 'object' && userId._id) {
        return userId._id
      }

      // Otherwise return the userId as is (should be a string)
      return userId
    }

    if (isEditMode) {
      await dispatch(
        updatePost({
          userId: getUserId(formData.userId || editData.userId),
          postId: editData._id,
          formData: formDataToSend
        })
      )
    } else {
      await dispatch(
        createFakePost({
          userId: getUserId(formData.userId),
          formData: formDataToSend
        })
      )
    }

    handleClose()
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
      maxWidth='md'
      fullWidth
      keepMounted
      TransitionComponent={Transition}
      PaperProps={{
        sx: {
          overflow: 'visible',
          width: '600px',
          maxWidth: '95vw'
        }
      }}
    >
      <DialogTitle>
        <Typography variant='h5' component='span'>
          {isEditMode ? 'Edit Post' : 'Create Post'}
        </Typography>
        <DialogCloseButton onClick={handleClose}>
          <CloseIcon />
        </DialogCloseButton>
      </DialogTitle>
      <DialogContent className='flex flex-col gap-4 py-4'>
        <Grid container spacing={3}>
          {isEditMode && uploaderDetails && (
            <Grid item xs={12}>
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
            </Grid>
          )}

          {!isEditMode && (
            <Grid item xs={12}>
              <FormControl fullWidth variant='outlined'>
                <InputLabel>Select User</InputLabel>
                <Select
                  name='userId'
                  value={formData.userId}
                  onChange={handleInputChange}
                  label='Select User'
                  disabled={loading}
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
              </FormControl>
            </Grid>
          )}

          <Grid item xs={12}>
            <Autocomplete
              multiple
              options={getAutocompleteOptions()}
              getOptionLabel={opt => opt.name || ''}
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
                    <Avatar
                      src={getFullImageUrl(option.image)}
                      alt={option.name}
                      sx={{ width: 24, height: 24, mr: 1 }}
                    />
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
          </Grid>

          <Grid item xs={12}>
            <Autocomplete
              multiple
              options={hashtags}
              value={formData.hashTags}
              getOptionLabel={option => option.hashTag}
              onChange={handleHashtagChange}
              isOptionEqualToValue={(option, value) => option._id === value._id}
              renderInput={params => (
                <TextField {...params} label='Hashtags' placeholder='Select hashtags' variant='outlined' />
              )}
              renderTags={(value, getTagProps) =>
                value.map((option, index) => {
                  const { key, ...chipProps } = getTagProps({ index })

                  return (
                    <Chip
                      key={option._id || key}
                      {...chipProps}
                      label={option.hashTag}
                      color='primary'
                      variant='outlined'
                      size='small'
                    />
                  )
                })
              }
            />
          </Grid>

          <Grid item xs={12}>
            <TextField
              fullWidth
              label='Caption'
              name='caption'
              value={formData.caption}
              onChange={handleInputChange}
              multiline
              rows={3}
              variant='outlined'
            />
          </Grid>

          <Grid item xs={12}>
            <Box>
              <Typography variant='subtitle1' gutterBottom>
                Post Images
              </Typography>
              <Button variant='outlined' component='label' startIcon={<AddPhotoAlternateIcon />} className='mb-3'>
                Add Images
                <input type='file' hidden accept='image/*' multiple onChange={handleImageChange} />
              </Button>

              <Box className='grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2 mt-3'>
                {imagePreviewUrls.map((url, index) => (
                  <Box key={index} className='relative'>
                    <img src={url} alt={`Preview ${index}`} className='w-full h-32 object-cover rounded' />
                    <IconButton
                      size='small'
                      className='absolute top-1 right-1'
                      color='error'
                      onClick={() => removeImage(index)}
                    >
                      <DeleteIcon />
                    </IconButton>
                  </Box>
                ))}
              </Box>
            </Box>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} variant='tonal' color='secondary' disabled={loading}>
          Cancel
        </Button>
        <Button
          onClick={handleSubmit}
          variant='contained'
          color='primary'
          disabled={loading || (!isEditMode && !formData.userId) || imagePreviewUrls.length === 0}
        >
          {loading ? <CircularProgress size={24} color='inherit' /> : isEditMode ? 'Update Post' : 'Create Post'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default PostDialog
