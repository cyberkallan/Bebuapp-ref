'use client'

import { useEffect, useState } from 'react'

import { useDispatch } from 'react-redux'




// MUI Imports
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'



import { Slide } from '@mui/material'


import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

const Transition = forwardRef(function Transition(props, ref) {
  return <Slide direction='up' ref={ref} {...props} />
})

// Actions


// Form validation
import { yupResolver } from '@hookform/resolvers/yup'
import { useForm } from 'react-hook-form'
import * as yup from 'yup'

import { createListener, fetchListeners, updateListener } from '@/redux-store/slices/listener'

import { getFullImageUrl } from '@/utils/commonfunctions'
import DialogCloseButton from '@/components/dialogs/DialogCloseButton'

// Utilities
// import { uploadImage } from '@/utils/uploadImage'





const ITEM_HEIGHT = 48
const ITEM_PADDING_TOP = 8

const MenuProps = {
  PaperProps: {
    style: {
      maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
      width: 250
    }
  }
}

// Define validation schema
const schema = yup.object().shape({
  name: yup.string().required('Name is required'),
  email: yup.string().email('Enter a valid email').required('Email is required'),
  selfIntro: yup.string().required('Self introduction is required'),
  language: yup.array().min(1, 'At least one language is required'),
  talkTopics: yup.array().min(1, 'At least one talk topic is required'),
  ratePrivateVideoCall: yup.number().min(0, 'Must be at least 0').required('Rate is required'),
  ratePrivateAudioCall: yup.number().min(0, 'Must be at least 0').required('Rate is required'),
  rateRandomVideoCall: yup.number().min(0, 'Must be at least 0').required('Rate is required'),
  rateRandomAudioCall: yup.number().min(0, 'Must be at least 0').required('Rate is required'),
  experience: yup.string()
})

const ListenerDialog = ({ open, onClose, listener = null }) => {
  const dispatch = useDispatch()
  const [loading, setLoading] = useState(false)
  const [imageFile, setImageFile] = useState(null)
  const [previewImage, setPreviewImage] = useState('')
  const [languages, setLanguages] = useState([])
  const [talkTopics, setTalkTopics] = useState([])

  // Fetch available languages and talk topics from API in a real implementation
  useEffect(() => {
    setLanguages(['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Hindi', 'Arabic'])
    setTalkTopics([
      'Loneliness',
      'Relationship',
      'Family',
      'Career',
      'Mental Health',
      'Self-Improvement',
      'Entertainment'
    ])
  }, [])

  // Form setup
  const {
    control,
    handleSubmit,
    reset,
    setValue,
    formState: { errors }
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: {
      name: '',
      email: '',
      selfIntro: '',
      language: [],
      talkTopics: [],
      ratePrivateVideoCall: 0,
      ratePrivateAudioCall: 0,
      rateRandomVideoCall: 0,
      rateRandomAudioCall: 0,
      experience: ''
    }
  })

  // Initialize form with listener data when editing
  useEffect(() => {
    if (listener) {
      reset({
        name: listener.name || '',
        email: listener.email || '',
        selfIntro: listener.selfIntro || '',
        language: listener.language || [],
        talkTopics: listener.talkTopics || [],
        ratePrivateVideoCall: listener.ratePrivateVideoCall || 0,
        ratePrivateAudioCall: listener.ratePrivateAudioCall || 0,
        rateRandomVideoCall: listener.rateRandomVideoCall || 0,
        rateRandomAudioCall: listener.rateRandomAudioCall || 0,
        experience: listener.experience || ''
      })

      // Set preview image if exists
      if (listener.image) {
        setPreviewImage(getFullImageUrl(listener.image))
      }
    } else {
      reset({
        name: '',
        email: '',
        selfIntro: '',
        language: [],
        talkTopics: [],
        ratePrivateVideoCall: 0,
        ratePrivateAudioCall: 0,
        rateRandomVideoCall: 0,
        rateRandomAudioCall: 0,
        experience: ''
      })
      setPreviewImage('')
      setImageFile(null)
    }
  }, [listener, reset])

  const handleImageChange = e => {
    if (e.target.files[0]) {
      const file = e.target.files[0]

      setImageFile(file)
      setPreviewImage(URL.createObjectURL(file))
    }
  }

  const onSubmit = async data => {
    try {
      setLoading(true)

      const formData = new FormData()

      // Add all form fields to FormData
      Object.keys(data).forEach(key => {
        if (key === 'language' || key === 'talkTopics') {
          // Handle arrays by joining with commas
          formData.append(key, data[key].join(','))
        } else {
          formData.append(key, data[key])
        }
      })

      // Add image if selected
      if (imageFile) {
        formData.append('image', imageFile)
      }

      if (listener) {
        // Update existing listener
        await dispatch(updateListener({ listenerId: listener._id, formData }))
      } else {
        // Create new listener
        await dispatch(createListener(formData))
      }

      // Refresh the listeners list
      dispatch(fetchListeners())
      onClose()
    } catch (error) {
      console.error('Error saving listener:', error)
    } finally {
      setLoading(false)
    }
  }

  return (

    
    <Dialog
          open={open}
          onClose={onClose}
          keepMounted
          TransitionComponent={Transition}
          aria-labelledby='faq-dialog-title'
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
          <DialogTitle id='faq-dialog-title'>
            <Typography variant='h5' component='span'>
              {editData ? 'Edit FAQ' : 'Create FAQ'}
            </Typography>

            <DialogCloseButton onClick={handleClose}>
              <i className='tabler-x' />
            </DialogCloseButton>
          </DialogTitle>
    
          <DialogContent className='flex flex-col gap-4 py-4'>
            {/* <FormControl fullWidth>
              <InputLabel id='category-select-label'>Category</InputLabel>
              <Select
                labelId='category-select-label'
                id='category-select'
                value={formData.category}
                label='Category'
                onChange={e => handleChange('category', e.target.value)}
              >
                <MenuItem value='User'>User</MenuItem>
                <MenuItem value='Listener'>Listener</MenuItem>
              </Select>
            </FormControl> */}
    
            <TextField
              label='Question'
              fullWidth

              // value={formData.question}
              // error={!!errors.question}
              // helperText={errors.question || ''}
              // onChange={e => handleChange('question', e.target.value)}
              placeholder='Enter the question'
              multiline
              rows={2}
            />
    
            <TextField
              label='Answer'
              fullWidth

              // value={formData.answer}
              // error={!!errors.answer}
              // helperText={errors.answer || ''}
              // onChange={e => handleChange('answer', e.target.value)}
              placeholder='Enter the answer'
              multiline
              rows={4}
            />
          </DialogContent>
    
          <DialogActions className='p-6 pt-0'>
            <Button variant='outlined' >
              Cancel
            </Button>
            <Button
              variant='contained'
              
              // onClick={handleSubmit}
              // disabled={loading}
              // startIcon={loading && <CircularProgress size={20} />}
            >
              {editData ? 'Update' : 'Create'}
            </Button>
          </DialogActions>
        </Dialog>
  )
}

export default ListenerDialog
