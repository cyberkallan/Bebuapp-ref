'use client'

import { Box, Typography } from '@mui/material'

import ListenerListTable from './ListenerListTable'

const ListenerManagement = () => {
  return (
    <Box className='pbs-6 container'>
      <Box className='flex justify-between items-center flex-wrap gap-4 mbe-6'>
        <Typography variant='h4' className='font-bold'>
          Listeners Management
        </Typography>
      </Box>
      <ListenerListTable />
    </Box>
  )
}

export default ListenerManagement
