'use client'

import Paper from '@mui/material/Paper'
import Skeleton from '@mui/material/Skeleton'

// Transaction loading skeleton
const TransactionSkeleton = () => (
  <Paper elevation={0} className='p-4 border rounded-md mb-3'>
    <div className='flex items-start gap-3'>
      <Skeleton variant='rounded' width={40} height={40} />
      <div className='flex-grow'>
        <div className='flex justify-between items-start'>
          <div>
            <Skeleton width={150} height={24} />
            <Skeleton width={180} height={18} />
          </div>
          <div className='text-right'>
            <Skeleton width={80} height={24} />
            <Skeleton width={60} height={18} />
          </div>
        </div>
      </div>
    </div>
  </Paper>
)

export default TransactionSkeleton
