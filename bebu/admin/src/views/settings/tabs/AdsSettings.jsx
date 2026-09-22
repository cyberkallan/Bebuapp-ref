'use client'

import React from 'react'

import { useSelector, useDispatch } from 'react-redux'

// MUI Imports
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'

// Redux Actions
import { updateSettings } from '@/redux-store/slices/settings'

const AdsSettings = () => {
  const dispatch = useDispatch()
  const { settings, loading } = useSelector(state => state.settings)

  const handleInputChange = (field, value) => {
    if (settings?._id) {
      dispatch(updateSettings({ _id: settings._id, [field]: value }))
    }
  }

  if (!settings) return null

  return <Box>Ads</Box>
}

export default AdsSettings
