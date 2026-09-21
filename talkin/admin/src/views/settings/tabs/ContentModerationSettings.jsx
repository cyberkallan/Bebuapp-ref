import React, { useEffect, useMemo, useState } from 'react'

// MUI Imports
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import { useSelector, useDispatch } from 'react-redux'
import { Divider, TextField, Button, FormControl, FormHelperText, Chip, Autocomplete } from '@mui/material'
import { toast } from 'react-toastify'

import { updateSettings } from '@/redux-store/slices/settings'

const ContentModerationSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)
  



  const [jsonError, setJsonError] = useState('')

  const [formData, setFormData] = useState({
    _id: '',
    sightengineUser: '',
    sightengineApiSecret: '',
    videoBanned: [],
    postBanned: []
  })

  const keywordOptions = useMemo(
    () => [
      { id: '1', label: 'nudity and adult content' },
      { id: '2', label: 'hate and offensive signs' },
      { id: '3', label: 'violence' },
      { id: '4', label: 'gore and disgusting' },
      { id: '5', label: 'weapons' },
      { id: '6', label: 'smoking and tobacco products' },
      { id: '7', label: 'recreational and medical drugs' },
      { id: '8', label: 'gambling' },
      { id: '9', label: 'alcoholic beverages' },
      { id: '10', label: 'money and bank notes' },
      { id: '11', label: 'self harm' }
    ],
    []
  )

  useEffect(() => {
    if (settings) {
      setFormData({
        _id: settings._id || '',
        sightengineUser: settings.sightengineUser || '',
        sightengineApiSecret: settings.sightengineApiSecret || '',
        videoBanned: settings.videoBanned?.filter(id => id) || [],
        postBanned: settings.postBanned?.filter(id => id) || []
      })
    }
  }, [settings])

  const handleInputChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const handleAutocompleteChange = (field, event, newValue) => {
    const selectedIds = newValue.map(opt => opt.id)

    setFormData(prev => ({ ...prev, [field]: selectedIds }))
  }

  const handleSubmit = async () => {
    

    if (jsonError) return

    try {
      if (settings?._id) {
        await dispatch(updateSettings(formData))
        console.log('Settings updated successfully')
      }
    } catch (error) {
      // Handle error
      console.error('Failed to update settings:', error)
    }
  }

  return (
    <Box>
      <Grid container spacing={6}>
        <Grid item xs={12}>
          <Box sx={{ mb: 4 }}>
            <Typography variant='h5'>Content Moderation</Typography>
          </Box>
          {/* Sightengine Settings */}
          <Card sx={{ mb: 4 }}>
            <CardContent>
              <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-eye-check mr-2' />
                Configure Sightengine for content moderation
              </Typography>
              <Divider sx={{ mb: 3 }} />
              <Grid container spacing={4}>
                <Grid item xs={12} md={6}>
                  <TextField
                    fullWidth
                    label='Sightengine User'
                    value={formData.sightengineUser || ''}
                    onChange={e => handleInputChange('sightengineUser', e.target.value)}
                  />
                </Grid>
                <Grid item xs={12} md={6}>
                  <TextField
                    fullWidth
                    label='Sightengine API Secret'
                    value={formData.sightengineApiSecret || ''}
                    onChange={e => handleInputChange('sightengineApiSecret', e.target.value)}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
          <Card>
            <CardContent>
              <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                <i className='tabler-shield mr-2' />
                Content Moderation Keywords
              </Typography>

              <Divider sx={{ mb: 3 }} />

              <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                  <FormControl fullWidth>
                    <Autocomplete
                      multiple
                      options={keywordOptions}
                      getOptionLabel={option => `${option.label}`}
                      value={keywordOptions.filter(opt => (formData.videoBanned || []).includes(opt.id))}
                      onChange={(event, newValue) => handleAutocompleteChange('videoBanned', event, newValue)}
                      renderTags={(value, getTagProps) =>
                        value.map((opt, index) => {
                          const { key, ...tagProps } = getTagProps({ index }) // extract key

                          return (
                            <Chip
                              key={key} // ✅ key explicitly set
                              label={`${opt.label}`}
                              {...tagProps} // ✅ spread the rest
                            />
                          )
                        })
                      }
                      renderInput={params => (
                        <TextField {...params} label='Video Banned Keywords' placeholder='Select keywords' />
                      )}
                      disableCloseOnSelect
                    />

                    <FormHelperText>Select keywords that should be banned in videos</FormHelperText>
                  </FormControl>
                </Grid>
                <Grid item xs={12} md={6}>
                  <FormControl fullWidth>
                    <Autocomplete
                      multiple
                      id='post-banned-keywords'
                      options={keywordOptions}
                      getOptionLabel={option => `${option.label}`}
                      value={keywordOptions.filter(opt => (formData.postBanned || []).includes(opt.id))}
                      onChange={(event, newValue) => handleAutocompleteChange('postBanned', event, newValue)}
                      renderTags={(value, getTagProps) =>
                        value.map((opt, index) => {
                          const { key, ...tagProps } = getTagProps({ index }) // extract key

                          return (
                            <Chip
                              key={key} // ✅ key explicitly set
                              label={`${opt.label}`}
                              {...tagProps} // ✅ spread the rest
                            />
                          )
                        })
                      }
                      renderInput={params => (
                        <TextField {...params} label='Post Banned Keywords' placeholder='Select keywords' />
                      )}
                      disableCloseOnSelect
                    />
                    <FormHelperText>Select keywords that should be banned in posts</FormHelperText>
                  </FormControl>
                </Grid>
              </Grid>
            </CardContent>

            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                <Button variant='contained' color='primary' onClick={handleSubmit} disabled={loading || !!jsonError}>
                  {loading ? 'Saving...' : 'Save Changes'}
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  )
}

export default ContentModerationSettings
