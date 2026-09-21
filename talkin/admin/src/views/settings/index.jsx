'use client'

import React, { useState, useEffect } from 'react'

import { useRouter, useSearchParams } from 'next/navigation'

import { useDispatch, useSelector } from 'react-redux'

// MUI Imports
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Typography from '@mui/material/Typography'
import Tab from '@mui/material/Tab'
import Tabs from '@mui/material/Tabs'

// Redux Actions
import { fetchReportReasons } from '@/redux-store/slices/reportReasons'
import { fetchSettings } from '@/redux-store/slices/settings'

// Tab Components
import ReportReasonSettings from './tabs/ReportReasonSettings'
import GeneralSettings from './tabs/GeneralSettings'
import CurrencySettings from './tabs/CurrencySettings'
import PaymentSettings from './tabs/PaymentSettings'
import AdsSettings from './tabs/AdsSettings'
import ContentModerationSettings from './tabs/ContentModerationSettings'
import WithdrawalSettings from './tabs/WithdrawalSettings'
import ProfileManagement from './tabs/ProfileManageMent'

// Tab labels and values
const tabs = [
  { label: 'General', value: 'general' },
  { label: 'Payment', value: 'payment' },
  { label: 'Currency', value: 'currency' },
  { label: 'Withdrawal', value: 'withdrawal' }
]

const Settings = () => {
  const dispatch = useDispatch()
  const router = useRouter()
  const searchParams = useSearchParams()

  const tabParam = searchParams.get('tab')

  const [activeTab, setActiveTab] = useState(tabs.some(tab => tab.value === tabParam) ? tabParam : 'general')

  // Handle tab change
  const handleTabChange = (event, newValue) => {
    setActiveTab(newValue)

    const params = new URLSearchParams(searchParams.toString())

    params.set('tab', newValue)
    router.push(`?${params.toString()}`)
  }

  
  


  useEffect(() => {
    if (activeTab === 'general' || activeTab === 'payment' || activeTab === 'ads' || activeTab === 'withdrawal') {
      dispatch(fetchSettings())
    }

  }, [activeTab, dispatch])

  // Render tab content based on active tab
  const renderTabContent = () => {
    switch (activeTab) {
      case 'general':
        return <GeneralSettings />
      case 'payment':
        return <PaymentSettings />
      case 'currency':
        return <CurrencySettings />
      case 'withdrawal':
        return <WithdrawalSettings />
      default:
        return <Typography>Select a tab</Typography>
    }
  }

  return (
    <Grid container spacing={6}>
      <Grid item size={12}>
        <Card>
          <CardContent>
            <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 4 }}>
              <Tabs
                value={activeTab}
                onChange={handleTabChange}
                aria-label='settings tabs'
                variant='scrollable'
                scrollButtons='auto'
              >
                {tabs.map(tab => (
                  <Tab key={tab.value} label={tab.label} value={tab.value} />
                ))}
              </Tabs>
            </Box>
            <Box>{renderTabContent()}</Box>
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  )
}

export default Settings
