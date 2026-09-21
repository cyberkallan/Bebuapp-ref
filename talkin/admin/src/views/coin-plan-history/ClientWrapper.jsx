'use client'

import React, { Suspense } from 'react'

// MUI Imports
import CircularProgress from '@mui/material/CircularProgress'

// Component Imports
import CoinPlanHistory from './index'

const ClientWrapper = () => {
  return (
    <Suspense
      fallback={
        <div className='flex justify-center items-center h-[400px]'>
          <CircularProgress />
        </div>
      }
    >
      <CoinPlanHistory />
    </Suspense>
  )
}

export default ClientWrapper
