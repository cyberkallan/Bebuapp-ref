import React, { useEffect, useState } from 'react'

import {
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  Divider,
  Grid,
  InputAdornment,
  TextField,
  Typography
} from '@mui/material'
import { useSelector, useDispatch } from 'react-redux'
import { toast } from 'react-toastify'

import { updateSettings } from '@/redux-store/slices/settings'
import HoverPopover from '@/common/HoverPopover'
import { toolTipData } from '@/settingTooltip'

const WithdrawalSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)
  




  const [jsonError, setJsonError] = useState(null)

  // Using string values for inputs to allow empty fields
  const [formData, setFormData] = useState({
    _id: '',
    minimumCoinsForConversion: '',
    minimumCoinsForPayout: '',
    agencyMinPayout: ''
  })

  useEffect(() => {
    if (settings) {
      setFormData({
        _id: settings._id || '',
        minimumCoinsForConversion: settings.minimumCoinsForConversion?.toString() || '',
        minimumCoinsForPayout: settings.minimumCoinsForPayout?.toString() || '',
        agencyMinPayout: settings.agencyMinPayout?.toString() || ''
      })
    }

   
  }, [settings])

  const handleFieldChange = (field, value) => {
    // Allow empty string or valid numbers
    if (value === '' || !isNaN(value)) {
      setFormData(prev => ({
        ...prev,
        [field]: value
      }))
    }
  }

  const validateForm = () => {
    // Convert empty strings to 0 for validation
    const minimumCoinsForConversion =
      formData.minimumCoinsForConversion === '' ? 0 : Number(formData.minimumCoinsForConversion)

    const minimumCoinsForPayout = formData.minimumCoinsForPayout === '' ? 0 : Number(formData.minimumCoinsForPayout)

    if (minimumCoinsForConversion < 0 || minimumCoinsForPayout < 0) {
      setJsonError('Minimum coins cannot be negative')

      return false
    }

    setJsonError(null)

    return true
  }

  const handleSubmit = async () => {
    

    if (!validateForm()) return

    // Convert string values to numbers for submission
    const dataToSubmit = {
      ...formData,
      minimumCoinsForConversion:
        formData.minimumCoinsForConversion === '' ? 0 : Number(formData.minimumCoinsForConversion),
      minimumCoinsForPayout: formData.minimumCoinsForPayout === '' ? 0 : Number(formData.minimumCoinsForPayout)
    }

    dispatch(updateSettings(dataToSubmit))
  }

  return (
    <Box>
      <Box sx={{ mb: 4 }} className='flex justify-between gap-4 items-start md:items-center md:flex-row flex-col'>
        <Typography variant='h5'>Payout Setting</Typography>
        <Box className='flex justify-end mt-4'>
          <Button
            variant='contained'
            color='primary'
            onClick={handleSubmit}
            disabled={loading || !!jsonError}
           
            startIcon={
              loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : <i className='tabler-device-floppy' />
            }
          >
            Save Changes
          </Button>
        </Box>
      </Box>

      <Card sx={{ mb: 4 }} >
        <CardContent>
          {/* <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-settings mr-2' />
            Minimum Coin Setting
          </Typography> */}

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                      <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                        <i className='tabler-settings mr-2' />
                       Minimum Coin Setting
                      </Typography>
                      <HoverPopover
                        popoverContent={
                          <>
                            <Box>
                              <Typography
                                variant='subtitle1'
                                sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                              >
                                {toolTipData['minimumCoinsForConversion'].title}
                              </Typography>
                              <Divider sx={{ mb: 0 }} />
                              <p>{toolTipData['minimumCoinsForConversion'].tooltip}</p>
                            </Box>
                          </>
                        }
                      >
                        <i className='tabler-info-circle' />
                      </HoverPopover>
                    </Box>
          <Divider sx={{ mb: 3 }} />
          <Grid container spacing={3}>
            <Grid item xs={12} size={5.9} md={5.9}>
              <TextField
                fullWidth
                type='text'
                label={`${settings?.currency?.name || 'Currency'}`}
                value={1}
                disabled={true}
                InputProps={{
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        {settings?.currency?.name || 'Currency'}
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
            <Grid item xs={12} md={0.1} sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              =
            </Grid>
            <Grid item xs={12} size={5.9}>
              <TextField
                fullWidth
                type='text'
                label='Coins'
                value={formData.minimumCoinsForConversion || '' }
                onChange={e => handleFieldChange('minimumCoinsForConversion', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        coins
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>

            {/* <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              type='text'
              label='Minimum Coins Payout For Agency'
              value={formData.agencyMinPayout}
              onChange={e => handleFieldChange('agencyMinPayout', e.target.value)}
              InputProps={{
                inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                endAdornment: (
                  <InputAdornment position='end'>
                    <Typography variant='caption' color='text.secondary'>
                      coins
                    </Typography>
                  </InputAdornment>
                )
              }}
            />
          </Grid> */}
          </Grid>
        </CardContent>
      </Card>

      <Card sx={{ mb: 4 }} >
        <CardContent>
          {/* <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
            <i className='tabler-settings mr-2' />
            Minimum Coin Payout Setting
          </Typography> */}

          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                      <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                        <i className='tabler-settings mr-2' />
                       Minimum Coin Payout Setting
                      </Typography>
                      <HoverPopover
                        popoverContent={
                          <>
                            <Box>
                              <Typography
                                variant='subtitle1'
                                sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                              >
                                {toolTipData['minimumCoinsForPayout'].title}
                              </Typography>
                              <Divider sx={{ mb: 0 }} />
                              <p>{toolTipData['minimumCoinsForPayout'].tooltip}</p>
                            </Box>
                          </>
                        }
                      >
                        <i className='tabler-info-circle' />
                      </HoverPopover>
                    </Box>
          <Divider sx={{ mb: 3 }} />
          <Grid container spacing={3}>
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Minimum Coins Payout For Listener'
                value={formData.minimumCoinsForPayout || ''}
                onChange={e => handleFieldChange('minimumCoinsForPayout', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        coins
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
    </Box>
  )
}

export default WithdrawalSettings
