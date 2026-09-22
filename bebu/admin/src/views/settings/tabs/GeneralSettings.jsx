'use client'

import { useEffect, useState } from 'react'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import CircularProgress from '@mui/material/CircularProgress'
import Divider from '@mui/material/Divider'
import FormControlLabel from '@mui/material/FormControlLabel'
import Grid from '@mui/material/Grid'
import InputAdornment from '@mui/material/InputAdornment'
import Switch from '@mui/material/Switch'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import { toast } from 'react-toastify'

// Redux Actions
import { toggleSetting, updateSettings } from '@/redux-store/slices/settings'
import HoverPopover from '@/common/HoverPopover'
import { toolTipData } from '@/settingTooltip'

const GeneralSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading, error } = useSelector(state => state.settings)



  



  const [formData, setFormData] = useState({
    _id: '',
    privateKey: {},
    privateCallRate: '',
    loginBonus: '',
    durationOfShorts: '',
    minCoinsToCashOut: '',
    minCoinsForPayout: '',
    pkEndTime: '',
    listenerPrivacyPolicyUrl: '',
    aboutUsUrl: '',
    helpdeskEmail: '',
    userPrivacyPolicyUrl: '',
    shortsEffectEnabled: false,
    androidEffectLicenseKey: '',
    iosEffectLicenseKey: '',
    watermarkEnabled: false,
    watermarkIcon: '',
    agoraAppId: '',
    agoraAppCertificate: '',
    isDummyData: false,
    videoCallRatePrivate: '',
    audioCallRatePrivate: '',
    videoCallRateRandom: '',
    audioCallRateRandom: '',
    dailyLoginBonusCoins: '',
    isDemoContentEnabled: '',
    isApplicationLive: '',
    allowBecomeHostOption: ''
  })

  const [privateKeyJson, setPrivateKeyJson] = useState('')
  const [jsonError, setJsonError] = useState('')

  // Update form data when settings are fetched
  useEffect(() => {
    if (settings) {
      setFormData({
        ...settings,
        _id: settings._id || '',
        loginBonus: settings.loginBonus?.toString() || '',
        durationOfShorts: settings.durationOfShorts?.toString() || '',
        pkEndTime: settings.pkEndTime?.toString() || '',
        minCoinsToCashOut: settings.minCoinsToCashOut?.toString() || '',
        minCoinsForPayout: settings.minCoinsForPayout?.toString() || '',
        userPrivacyPolicyUrl: settings.userPrivacyPolicyUrl || '',
        listenerPrivacyPolicyUrl: settings.listenerPrivacyPolicyUrl || '',
        aboutUsUrl: settings.aboutUsUrl || '',
        helpdeskEmail: settings.helpdeskEmail || '',
        shortsEffectEnabled: settings.shortsEffectEnabled || false,
        androidEffectLicenseKey: settings.androidEffectLicenseKey || '',
        iosEffectLicenseKey: settings.iosEffectLicenseKey || '',
        watermarkEnabled: settings.watermarkEnabled || false,
        watermarkIcon: settings.watermarkIcon || '',
        zegoAppId: settings.zegoAppId || '',
        zegoAppSignIn: settings.zegoAppSignIn || '',
        isDummyData: settings.isDummyData || false,
        videoCallRatePrivate: settings.videoCallRatePrivate || 0,
        audioCallRatePrivate: settings.audioCallRatePrivate || 0,
        videoCallRateRandom: settings.videoCallRateRandom || 0,
        audioCallRateRandom: settings.audioCallRateRandom || 0,
        dailyLoginBonusCoins: settings.dailyLoginBonusCoins || 0,
        adminCommissionPercent: settings.adminCommissionPercent || 0,
        allowBecomeHostOption: settings.allowBecomeHostOption || false,
        isApplicationLive: settings.isApplicationLive || false,
        isDemoContentEnabled: settings.isDemoContentEnabled || false
      })

      if (settings.privateKey) {
        try {
          setPrivateKeyJson(JSON.stringify(settings.privateKey, null, 2))
        } catch (err) {
          setPrivateKeyJson(JSON.stringify({}))
        }
      }
    }

   
  }, [settings])

  const handleFieldChange = (field, value) => {
    // Handle numeric fields differently
    if (
      [
        'privateCallRate',
        'loginBonus',
        'durationOfShorts',
        'pkEndTime',
        'minCoinsToCashOut',
        'minCoinsForPayout'
      ].includes(field)
    ) {
      // Allow empty string or valid numbers
      if (value === '' || !isNaN(value)) {
        setFormData(prev => ({
          ...prev,
          [field]: value
        }))
      }
    } else {
      setFormData(prev => ({
        ...prev,
        [field]: value
      }))
    }
  }

  const handleJsonChange = value => {
    setPrivateKeyJson(value)

    try {
      if (value.trim()) {
        const parsedJson = JSON.parse(value)

        setFormData(prev => ({
          ...prev,
          privateKey: parsedJson
        }))
        setJsonError('')
      } else {
        setFormData(prev => ({
          ...prev,
          privateKey: {}
        }))
      }
    } catch (err) {
      setJsonError('Invalid JSON format')
    }
  }

  const handleToggle = type => {
   

    if (settings?._id) {
      dispatch(toggleSetting({ settingId: settings._id, type }))
    }
  }

  const handleSubmit = async () => {
    

    if (jsonError) return

    if (settings?._id) {
      // Prepare data for submission by converting string values to numbers
      const dataToSubmit = {
        ...formData,
        privateCallRate: formData.privateCallRate === '' ? 0 : Number(formData.privateCallRate),
        loginBonus: formData.loginBonus === '' ? 0 : Number(formData.loginBonus),
        durationOfShorts: formData.durationOfShorts === '' ? 0 : Number(formData.durationOfShorts),
        pkEndTime: formData.pkEndTime === '' ? 0 : Number(formData.pkEndTime),
        minCoinsToCashOut: formData.minCoinsToCashOut === '' ? 0 : Number(formData.minCoinsToCashOut),
        minCoinsForPayout: formData.minCoinsForPayout === '' ? 0 : Number(formData.minCoinsForPayout),
        adminCommissionPercent: formData.adminCommissionPercent === '' ? 0 : Number(formData.adminCommissionPercent)
      }

      dispatch(updateSettings(dataToSubmit))
    }
  }

  if (!settings && loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4, alignItems: 'center', height: '55vh' }}>
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Alert severity='error' sx={{ mb: 4 }}>
        {error}
      </Alert>
    )
  }

  const handlePopoverOpen = event => {
    setAnchorEl(event.currentTarget)
  }

  const handlePopoverClose = () => {
    setAnchorEl(null)
  }

  return (
    <Box>
      {/* <Box sx={{ p: 5 }}>
        <HoverPopover popoverContent={"bdfb"}>
          <i className='tabler-info-circle' />
        </HoverPopover>
      </Box> */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant='h5'>General Setting</Typography>
        <Button
          variant='contained'
          color='primary'
          onClick={handleSubmit}
          disabled={loading || !!jsonError}
          startIcon={loading ? <CircularProgress color='white' size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box>

      {/* App Settings */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              App Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['dailyLoginBonusCoins'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['dailyLoginBonusCoins'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['adminCommissionPercent'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['adminCommissionPercent'].tooltip}</p>
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
                label='Daily Login Bonus'
                value={formData.dailyLoginBonusCoins}
                onChange={e => handleFieldChange('dailyLoginBonusCoins', e.target.value)}
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
            <Grid item size={6}>
              <TextField
                fullWidth
                type='text'
                label='Admin Commission Percent'
                value={formData.adminCommissionPercent || ''}
                onChange={e => handleFieldChange('adminCommissionPercent', e.target.value)}
                InputProps={{
                  inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                  endAdornment: (
                    <InputAdornment position='end'>
                      <Typography variant='caption' color='text.secondary'>
                        %
                      </Typography>
                    </InputAdornment>
                  )
                }}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Call Rate Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['audioCallRatePrivate'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['audioCallRatePrivate'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['videoCallRateRandom'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['videoCallRateRandom'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <div className='flex gap-3'>
            <Card className='w-full bg-transparent'>
              <CardContent className=''>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Private Rate
                </Typography>
                <Divider sx={{ mb: 3 }} />
                <div className='flex gap-3 flex-col'>
                  <Grid item xs={12} md={12}>
                    <TextField
                      fullWidth
                      type='text'
                      label='Private Audio Rate'
                      value={formData.audioCallRatePrivate || ''}
                      onChange={e => handleFieldChange('audioCallRatePrivate', e.target.value)}
                      InputProps={{
                        inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                        endAdornment: (
                          <InputAdornment position='end'>
                            <Typography variant='caption' color='text.secondary'>
                              coins/minute
                            </Typography>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>
                  <Grid item xs={12} md={12}>
                    <TextField
                      fullWidth
                      type='text'
                      label='Private Video Rate'
                      value={formData.videoCallRatePrivate || ''}
                      onChange={e => handleFieldChange('videoCallRatePrivate', e.target.value)}
                      InputProps={{
                        inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                        endAdornment: (
                          <InputAdornment position='end'>
                            <Typography variant='caption' color='text.secondary'>
                              coins/minute
                            </Typography>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>
                </div>
              </CardContent>
            </Card>
            <Card className='w-full'>
              <CardContent className=''>
                <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
                  <i className='tabler-settings mr-2' />
                  Random Rate
                </Typography>
                <Divider sx={{ mb: 3 }} />
                <div className='flex gap-3 flex-col'>
                  <Grid item xs={12} md={12}>
                    <TextField
                      fullWidth
                      type='text'
                      label='Random Audio Rate'
                      value={formData.audioCallRateRandom || ''}
                      onChange={e => handleFieldChange('audioCallRateRandom', e.target.value)}
                      InputProps={{
                        inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                        endAdornment: (
                          <InputAdornment position='end'>
                            <Typography variant='caption' color='text.secondary'>
                              coins/minute
                            </Typography>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>

                  <Grid item xs={12} md={12}>
                    <TextField
                      fullWidth
                      type='text'
                      label='Random Video Rate'
                      value={formData.videoCallRateRandom || ''}
                      onChange={e => handleFieldChange('videoCallRateRandom', e.target.value)}
                      InputProps={{
                        inputProps: { inputMode: 'numeric', pattern: '[0-9]*' },
                        endAdornment: (
                          <InputAdornment position='end'>
                            <Typography variant='caption' color='text.secondary'>
                              coins/minute
                            </Typography>
                          </InputAdornment>
                        )
                      }}
                    />
                  </Grid>
                </div>
              </CardContent>
            </Card>
          </div>
        </CardContent>
      </Card>

      {/* Agora settings keys */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Zego Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['zegoAppId'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['zegoAppId'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['zegoAppSignIn'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['zegoAppSignIn'].tooltip}</p>
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
                label='Zego App ID'
                value={formData.zegoAppId || ''}
                onChange={e => handleFieldChange('zegoAppId', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Zego App SignIn'
                value={formData.zegoAppSignIn || ''}
                onChange={e => handleFieldChange('zegoAppSignIn', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Policy Links */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-settings mr-2' />
              Policy Links
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['userPrivacyPolicyUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['userPrivacyPolicyUrl'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['listenerPrivacyPolicyUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['listenerPrivacyPolicyUrl'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['aboutUsUrl'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['aboutUsUrl'].tooltip}</p>
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
                label='Privacy Policy (User)'
                value={formData.userPrivacyPolicyUrl || ''}
                onChange={e => handleFieldChange('userPrivacyPolicyUrl', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='Privacy Policy Link (Listener)'
                value={formData.listenerPrivacyPolicyUrl || ''}
                onChange={e => handleFieldChange('listenerPrivacyPolicyUrl', e.target.value)}
              />
            </Grid>
            <Grid item size={6}>
              <TextField
                fullWidth
                label='About Us Link'
                value={formData.aboutUsUrl || ''}
                onChange={e => handleFieldChange('aboutUsUrl', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-help-octagon mr-2' />
              Support Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['helpdeskEmail'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['helpdeskEmail'].tooltip}</p>
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
                label='Support Email'
                value={formData.helpdeskEmail || ''}
                onChange={e => handleFieldChange('helpdeskEmail', e.target.value)}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Firebase Configuration */}
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
              <i className='tabler-brand-firebase mr-2' />
              Firebase Notification Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['privateKeyJson'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['privateKeyJson'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>

          <Divider sx={{ mb: 3 }} />

          <Typography variant='subtitle2' sx={{ mb: 2 }}>
            Private Key JSON
          </Typography>

          <TextField
            fullWidth
            multiline
            rows={10}
            value={privateKeyJson || ''}
            onChange={e => handleJsonChange(e.target.value)}
            placeholder={
              
                'Paste your Firebase private key JSON here'
               
            }
            error={!!jsonError}
            helperText={jsonError}
            sx={{
              '& .MuiInputBase-root': {
                fontFamily: 'monospace',
                fontSize: '0.875rem'
              }
            }}
          />

          {!jsonError && privateKeyJson && (
            <Alert severity='success' sx={{ mt: 2 }}>
              Firebase configuration is valid
            </Alert>
          )}

          <Alert severity='info' sx={{ mt: 3 }}>
            <Typography variant='body2'>
              Paste your Firebase service account JSON credentials from Firebase console. This is used for server-side
              Firebase operations.
            </Typography>
          </Alert>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant='subtitle1' sx={{ mb: 2, fontWeight: 500, display: 'flex', alignItems: 'center' }}>
               <i className='tabler-settings mr-2' />
            Other Setting
            </Typography>
            <HoverPopover
              popoverContent={
                <>
                  <Box>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['isDemoContentEnabled'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['isDemoContentEnabled'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['allowBecomeHostOption'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['allowBecomeHostOption'].tooltip}</p>
                  </Box>
                  <Box className='mt-2'>
                    <Typography
                      variant='subtitle1'
                      sx={{ marginBottom: 1, fontWeight: 500, display: 'flex', alignItems: 'center' }}
                    >
                      {toolTipData['isApplicationLive'].title}
                    </Typography>
                    <Divider sx={{ mb: 0 }} />
                    <p>{toolTipData['isApplicationLive'].tooltip}</p>
                  </Box>
                </>
              }
            >
              <i className='tabler-info-circle' />
            </HoverPopover>
          </Box>
          <Divider sx={{ mb: 3 }} />
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.isDemoContentEnabled || ''}
                  onChange={() => handleToggle('isDemoContentEnabled')}
                  name='isDemoContentEnabled'
                />
              }
              label='Demo Content'
            />
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.allowBecomeHostOption || ''}
                  onChange={() => handleToggle('allowBecomeHostOption')}
                  name='allowBecomeHostOption'
                />
              }
              label='Allow to become host'
            />
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <FormControlLabel
              control={
                <Switch
                  value={''}
                  checked={formData.isApplicationLive || ''}
                  onChange={() => handleToggle('isApplicationLive')}
                  name='isApplicationLive'
                />
              }
              label='Application Live'
            />
          </Box>
        </CardContent>
      </Card>

      {/* <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4 }}>
        <Button
          variant='contained'
          onClick={handleSubmit}
          disabled={loading || !!jsonError}
          startIcon={loading ? <CircularProgress size={20} /> : <i className='tabler-device-floppy' />}
        >
          Save Changes
        </Button>
      </Box> */}
    </Box>
  )
}

export default GeneralSettings
