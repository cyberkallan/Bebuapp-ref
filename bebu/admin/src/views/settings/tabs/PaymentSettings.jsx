'use client'

import React, { useEffect, useState } from 'react'

import { useSelector, useDispatch } from 'react-redux'

// MUI Imports
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'
import FormControlLabel from '@mui/material/FormControlLabel'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import { toast } from 'react-toastify'

import { Divider } from '@mui/material'

// Redux Actions
import { updateSettings, toggleSetting } from '@/redux-store/slices/settings'
import HoverPopover from '@/common/HoverPopover'
import { toolTipData } from '@/settingTooltip'

const PaymentSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)
  



  // Using string values for inputs to allow empty fields
  const [formData, setFormData] = useState({
    _id: '',
    stripePublicKey: '',
    stripeSecretKey: '',
    razorpayKeyId: '',
    razorpayKeySecret: '',
    flutterwavePublicKey: '',
    isStripeEnabled: false,
    isRazorpayEnabled: false,
    isFlutterwaveEnabled: false,
    isGooglePlayEnabled: false
  })

  useEffect(() => {
    if (settings) {
      setFormData({
        _id: settings._id || '',
        stripePublicKey: settings.stripePublicKey || '',
        stripeSecretKey: settings.stripeSecretKey || '',
        razorpayKeyId: settings.razorpayKeyId || '',
        razorpayKeySecret: settings.razorpayKeySecret || '',
        flutterwavePublicKey: settings.flutterwavePublicKey || '',
        isStripeEnabled: settings.isStripeEnabled || false,
        isRazorpayEnabled: settings.isRazorpayEnabled || false,
        isFlutterwaveEnabled: settings.isFlutterwaveEnabled || false,
        isGooglePlayEnabled: settings.isGooglePlayEnabled || false
      })
    }

  }, [settings])

  const handleToggle = type => {
    

    if (settings?._id) {
      dispatch(toggleSetting({ settingId: settings._id, type }))

      // Update local state too
      setFormData(prev => ({
        ...prev,
        [type]: !prev[type]
      }))
    }
  }

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))
  }

  const handleSubmit = () => {
    

    if (settings?._id) {
      dispatch(updateSettings(formData))
    }
  }

  // if (!settings) return null

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant='h5'>Payment Setting</Typography>
        <Button
          variant='contained'
          color='primary'
          onClick={handleSubmit}
          disabled={loading}
          startIcon={
            loading ? <CircularProgress size={20} sx={{ color: 'white' }} /> : <i className='tabler-device-floppy' />
          }
        >
          Save Changes
        </Button>
      </Box>

      <Grid container spacing={6}>
        {/* Stripe Settings */}
        <Grid item size={12}>
          <Card>
            <CardContent>
              {/* <Box sx={{ mb: 4 }}>
                <Typography variant='h6'>Stripe Setting</Typography>
              </Box> */}
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Stripe Setting
                </Typography>
                <HoverPopover
                  popoverContent={
                    <>
                      <Box>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['isStripeEnabled'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['isStripeEnabled'].tooltip}</p>
                      </Box>
                      <Box className='mt-2'>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['stripePublicKey'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['stripePublicKey'].tooltip}</p>
                      </Box>
                      <Box className='mt-2'>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['stripeSecretKey'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['stripeSecretKey'].tooltip}</p>
                      </Box>
                    </>
                  }
                >
                  <i className='tabler-info-circle' />
                </HoverPopover>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={formData.isStripeEnabled}
                      onChange={() => handleToggle('isStripeEnabled')}
                      name='stripeEnabled'
                    />
                  }
                  label='Enable Stripe'
                />
              </Box>
              <Grid container spacing={4}>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Stripe Publishable Key'
                    value={formData.stripePublicKey || ''}
                    onChange={e => handleInputChange('stripePublicKey', e.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Stripe Secret Key'
                    value={formData.stripeSecretKey || ''}
                    onChange={e => handleInputChange('stripeSecretKey', e.target.value)}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {/* Razorpay Settings */}
        <Grid item size={12}>
          <Card>
            <CardContent>
              {/* <Box sx={{ mb: 4 }}>
                <Typography variant='h6'>Razorpay Setting</Typography>
              </Box> */}

              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Razorpay Setting
                </Typography>
                <HoverPopover
                  popoverContent={
                    <>
                      <Box>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['isRazorpayEnabled'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['isRazorpayEnabled'].tooltip}</p>
                      </Box>
                      <Box className='mt-2'>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['razorpayKeyId'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['razorpayKeyId'].tooltip}</p>
                      </Box>
                      <Box className='mt-2'>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['razorpayKeySecret'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['razorpayKeySecret'].tooltip}</p>
                      </Box>
                    </>
                  }
                >
                  <i className='tabler-info-circle' />
                </HoverPopover>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={formData.isRazorpayEnabled}
                      onChange={() => handleToggle('isRazorpayEnabled')}
                      name='razorpayEnabled'
                    />
                  }
                  label='Enable Razorpay'
                />
              </Box>
              <Grid container spacing={4}>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Razorpay ID'
                    value={formData.razorpayKeyId || ''}
                    onChange={e => handleInputChange('razorpayKeyId', e.target.value)}
                  />
                </Grid>
                <Grid item size={6}>
                  <TextField
                    fullWidth
                    label='Razorpay Secret Key'
                    value={formData.razorpayKeySecret || ''}
                    onChange={e => handleInputChange('razorpayKeySecret', e.target.value)}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {/* Flutterwave Settings */}
        <Grid item size={12}>
          <Card>
            <CardContent>
              {/* <Box sx={{ mb: 4 }}>
                <Typography variant='h6'>Flutter wave Setting</Typography>
              </Box> */}
               <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Flutter wave Setting
                </Typography>
                <HoverPopover
                  popoverContent={
                    <>
                      <Box>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['isFlutterwaveEnabled'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['isFlutterwaveEnabled'].tooltip}</p>
                      </Box>
                      <Box className='mt-2'>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['flutterwavePublicKey'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['flutterwavePublicKey'].tooltip}</p>
                      </Box>
                    </>
                  }
                >
                  <i className='tabler-info-circle' />
                </HoverPopover>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={formData.isFlutterwaveEnabled}
                      onChange={() => handleToggle('isFlutterwaveEnabled')}
                      name='flutterwaveEnabled'
                    />
                  }
                  label='Enable Flutterwave'
                />
              </Box>
              <Grid container spacing={4}>
                <Grid item size={12}>
                  <TextField
                    fullWidth
                    label='Flutterwave ID'
                    value={formData.flutterwavePublicKey || ''}
                    onChange={e => handleInputChange('flutterwavePublicKey', e.target.value)}
                  />
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {/* Google Play Settings */}
        <Grid item size={12}>
          <Card>
            <CardContent>
              {/* <Box sx={{ mb: 4 }}>
                <Typography variant='h6'>Google Play Setting</Typography>
              </Box> */}
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Google Play Setting
                </Typography>
                <HoverPopover
                  popoverContent={
                    <>
                      <Box>
                        <Typography
                          variant='subtitle1'
                          sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                        >
                          {toolTipData['isGooglePlayEnabled'].title}
                        </Typography>
                        <Divider sx={{ mb: 0 }} />
                        <p>{toolTipData['isGooglePlayEnabled'].tooltip}</p>
                      </Box>
                    
                    </>
                  }
                >
                  <i className='tabler-info-circle' />
                </HoverPopover>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center' }}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={formData.isGooglePlayEnabled}
                      onChange={() => handleToggle('isGooglePlayEnabled')}
                      name='googlePlayEnabled'
                    />
                  }
                  label='Enable Google Play'
                />
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4 }}>
        <Button
          variant='contained'
          onClick={handleSubmit}
          disabled={loading}
          startIcon={loading ? <CircularProgress size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box> */}
    </Box>
  )
}

export default PaymentSettings
