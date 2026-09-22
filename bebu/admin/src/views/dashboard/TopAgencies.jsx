'use client'

import { useState } from 'react'

import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Typography from '@mui/material/Typography'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'

import CustomAvatar from '@/@core/components/mui/Avatar'
import { getInitials } from '@/utils/getInitials'
import { getFullImageUrl } from '@/utils/commonfunctions'

const renderAgencyImage = row => {
  if (row?.image) {
    return <CustomAvatar src={getFullImageUrl(row.image)} sx={{ mr: 3, width: 38, height: 38 }} />
  } else {
    return (
      <CustomAvatar skin='light' sx={{ mr: 3, width: 38, height: 38, fontSize: '1rem' }}>
        {getInitials(row?.agencyName)}
      </CustomAvatar>
    )
  }
}

const TopAgencies = ({ topAgencies }) => {
  if (!topAgencies || topAgencies.length === 0) {
    return null
  }

  return (
    <Card>
      <CardHeader
        title='Top Performing Agencies'
        subheader='Based on total earnings'
        subheaderTypographyProps={{ sx: { color: 'text.disabled' } }}
      />
      <CardContent>
        {topAgencies.map((row, index) => {
          return (
            <Box
              key={row.agencyCode}
              sx={{
                display: 'flex',
                alignItems: 'center',
                mb: index !== topAgencies.length - 1 ? 6 : undefined
              }}
            >
              {renderAgencyImage(row)}
              <Box sx={{ display: 'flex', flexDirection: 'column', flex: '1 1 0%' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <Typography sx={{ fontWeight: 500, mr: 1 }}>{row.agencyName}</Typography>
                    <img
                      src={row.countryFlagImage}
                      alt={row.country}
                      width={16}
                      height={12}
                      style={{ marginLeft: '4px' }}
                    />
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <Typography sx={{ color: 'primary.main', fontWeight: 500, mr: 1 }}>{row.totalEarnings}</Typography>
                    <Typography sx={{ color: 'text.disabled' }}>Coins</Typography>
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <Typography variant='body2'>{row.agencyCode}</Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <i className='tabler-users' fontSize='1rem' color='text.disabled' />
                    <Typography variant='body2' sx={{ ml: 1 }}>
                      {row.hostsCount} Hosts
                    </Typography>
                    <Typography variant='body2' sx={{ ml: 2, color: 'text.disabled' }}>
                      {row.commissionRate}% Commission
                    </Typography>
                  </Box>
                </Box>
              </Box>
            </Box>
          )
        })}
      </CardContent>
    </Card>
  )
}

export default TopAgencies
